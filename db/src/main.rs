use sqlx::{SqlitePool, Error};
use std::{
    process
};
use db::*;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    let db_url: &str = "sqlite://Rafferty-test.db";

    create_db(db_url).await;

    // Open Database
    let db: SqlitePool = match open_db(db_url).await {
	Ok(connection) => connection,
	Err(err) => {
	    eprintln!("Error opening database: {err}");
	    process::exit(1);
	}
    };
    println!("Database opened");

    match run_migrations(&db).await {
	Ok(_) => println!("Database Migrations Success"),
	Err(err) => {
	    eprintln!("Error: {err}");
	    println!("Migration Failed. Deleting Database");
	    delete_db(db_url, &db).await;
	    println!("Exiting");
	    return;
	}
    };

//    query_get_all_works(&db).await;
/*
    match query_get_musical_keys(&db).await {
	Ok(list) => {
	    for i in 0..list.len() {
		println!("{}\t{}", list[i].id, list[i].name);
	    }
	},
	Err(err) => eprintln!("Error: {err}")
    };
*/

    match query_get_song_characters(&db).await {
	Ok(s) => println!("{:?}", s),
	Err(err) => eprintln!("Error: {err}")
    };
    match update_character_id_by_name(&db, 27, "Claudia").await {
	Ok(s) => println!("{:?}", s),
	Err(err) => eprintln!("Error: {err}")
    };
    match query_get_song_characters(&db).await {
	Ok(s) => println!("{:?}", s),
	Err(err) => eprintln!("Error: {err}")
    };

    // Close Database
    match close_db(&db).await {
	Ok(()) => {},
	Err(err) => eprintln!("Error closing Database: {}", err),
    };
    println!("Database closed");
}