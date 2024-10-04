use sqlx::{
    Sqlite, SqlitePool, Error, FromRow, query, query_as, 
    migrate::{
	MigrateDatabase,
	Migrator
    }
};
use std::path::Path;
use std::fs::{remove_file, exists};
use std::{thread, time};

/*
#[proc_macro_derive(FieldNames)]
pub fn derive_field_names(input: TokenStream) -> TokenStream {
    let input  = parse_macro_input!(input as ItemStruct);
    input.fields.iter().
    TokenStream::from();
}
macro_rules! struct_field_names {
    (struct $name: ident { $($field_name:ident : $field_type: ty) , * }) => {
	// rewrite the struct
	struct $name {
	    $($field_name: $field_type),*
	}
	// define impl
	impl $name {
	    fn field_names() -> Vec<&'static str> {
		let mut v = Vec::new();
		$(v.push(stringify!($field_name));)*
		v
	    }
	}
    }
}
*/

#[derive(Clone, FromRow, Debug)]
struct Work {
    name: String,
    composer: String,
    librettist: String,
    language: String
}
impl Work {
    fn field_names() -> [&'static str; 4] {
	["name", "composer", "librettist", "language"]
    }
    fn print_field_names() {
	println!("\t{}", Work::field_names().join("\t|\t"));
	println!("_________________________________________________________________________________________");
    }
}

/* Structs todo:
	[X] composer
	[X] librettist
	[X] song
	[ ] variation
*/
#[derive(Clone, FromRow, Debug)]
#[sqlx(rename_all = "PascalCase")]
struct Composer {
    first_name: String,
    last_name: String,
    middle_names: String,
    born: u16,
    died: u16
}
#[derive(Clone, FromRow, Debug)]
#[sqlx(rename_all = "PascalCase")]
struct Librettist {
    first_name: String,
    last_name: String,
    middle_names: String,
    born: u16,
    died: u16
}
#[derive(Clone, FromRow, Debug)]
struct Song {
    uedr:		u32,
    work:		Work,
    original_key:	Option<String>,
    importance_rank:	String,
    name:		Option<String>,
    text_incipit:	Option<String>,
    notes:		Option<String>,
    link:		Option<String>,
    hold:		bool
}
#[derive(Clone, FromRow, Debug)]
struct Variation {
    uedr:		u32,
    vd_1:		u8,
    vd_2:		u8,
    musical_key:	Option<String>,
    instrument:		Option<String>,
    folder:		Option<String>,
    file_ext:		Option<String>,
    notes:		Option<String>
}
#[derive(Clone, FromRow, Debug)]
pub struct MusicalKey {
    pub id: u8,
    pub name: String
}

pub async fn query_get_musical_keys(db: &SqlitePool) -> Result<Vec<MusicalKey>, Error> {
    let musical_keys = query_as::<_, MusicalKey>("
    SELECT
	ID AS id,
	Name AS name
	FROM MusicalKey
    ")
	.fetch_all(db)
	.await?;
    return Ok(musical_keys);
}


// Could put these queries into impl's for each struct
pub async fn query_get_all_works(db: &SqlitePool) {
    let works = query_as::<_, Work>("
SELECT
  w.Name AS name,
  c.LastName || ', ' || c.FirstName AS composer,
  lib.LastName || ', ' || lib.FirstName AS librettist,
  lang.Name AS language
FROM Work w
INNER JOIN Composer c ON c.ID = w.ComposerID
INNER JOIN Librettist lib ON lib.ID = w.LibrettistID
INNER JOIN Language lang ON lang.ID = w.LanguageID;
    ")
        .fetch_all(db)
        .await
        .unwrap();

    Work::print_field_names();
    for work in works {
	println!("{}\t| {}\t| {}\t| {}",
	    if work.name.len() > 12 {work.name[..12].to_owned() + "..."} else {work.name},
	    work.composer,
	    work.librettist,
	    work.language
	);
    }
}

pub async fn open_db(db_url: &str) -> Result<SqlitePool, Error> {
    let db = SqlitePool::connect(db_url).await?;
    query("PRAGMA foreign_keys = ON;").execute(&db).await?;
    Ok(db)
}

pub async fn close_db(db: &SqlitePool) -> Result<(), Error> {
    db.close().await;
    Ok(())
}

pub async fn create_db(db_url: &str) {
    if !Sqlite::database_exists(db_url).await.unwrap_or(false) {
	println!("Creating Database {}...", db_url);
	match Sqlite::create_database(db_url).await {
	    Ok(_) => println!("Create db sucess"),
	    Err(error) => panic!("Error: {}", error),
	}
    } else {
	println!("Database already exists");
    }
}

pub async fn run_migrations(db: &SqlitePool) -> Result<(), Error> {
    let migration_results = Migrator::new(Path::new("./migrations"))
        .await
        .unwrap()
        .run(db)
        .await?;
    Ok(())
}

pub async fn delete_db(url: &str, db: &SqlitePool) {
    close_db(db).await.expect("Could not close database");
    println!("Database Connections closed");

    let file_name: &str = url.get((url.rfind('/').unwrap() + 1)..url.rfind('.').unwrap()).expect("Unable to truncate url");
    let exts: [&str; 3] = ["db", "shm", "wal"];
    for ext in exts.iter() {
	let file: String = file_name.to_owned() + "." + ext;
	if exists(&file).unwrap() {
	    match remove_file(&file) {
		Ok(_) => {},
		Err(err) => {thread::sleep(time::Duration::from_millis(2000)); remove_file(&file).unwrap()}
	    };
	}
    }
    println!("Database deleted successfully");
}