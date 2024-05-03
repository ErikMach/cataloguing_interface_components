use serde::{Deserialize};
use ureq::Error as UreqError;

use std::io::{Error, ErrorKind};
// Could be used to check the expiry of tokens... or we could just validate them.
//use std::time::{Duration, Instant};

use std::sync::RwLock;

// use ureq::serde_json;


#[derive(Deserialize)]
struct NewAccessTokenMsg {
    access_token: String,
    expires_in: usize
}


// Carl's deets (this app can only access one folder)
// App name: Cataloguing Interface
// Folder name: Cataloguing Interface
// "mf5f5d84oogxqku"
// "66wuagkmi8p0ok4"
// Auth token: 8WqwpcLlankAAAAAAAB7QhHSS7BD6TJkyZGg4jc4Vwc
// Refresh Token: NlbdxQXyzPcAAAAAAAAAAWs7cxw5r51kmLIsDW7Qq_ucQh2gFRmeqJkEc0_dPt6d

// Erik's examples
const APP_KEY: &str = "eeunnap4j9528ej";
const APP_SECRET: &str = "ee0wqr3uhod57ng";
const REFRESH_TOKEN: &str = "lFYUMZ3Sl1MAAAAAAAAAAdk1wiJubO_oA9e-FJRWdFESkz7WUaJL5enOuoFTI-qU";

pub static ACCESS_TOKEN: RwLock<String> = RwLock::new(String::new());  

/*
  STEPS
1. Create app on Carl's dropbox dev console
2. Retrieve:
	(a) APP_KEY
	(b) APP_SECRET
2. go to:
	https://www.dropbox.com/oauth2/authorize?token_access_type=offline&response_type=code&client_id=<APP_KEY>
3. Retrieve AUTHORIZATION_CODE
4. Run:
	curl https://api.dropbox.com/oauth2/token -d code=<AUTHORIZATION_CODE> -d grant_type=authorization_code -u <APP_KEY>:<APP_SECRET>
5. Retrieve REFRESH_TOKEN
*/


// To get new access token (life=14400s)
// curl https://api.dropbox.com/oauth2/token -d grant_type=refresh_token -d refresh_token=oDfT54975DfGh12345KlMnOpQrSt01a -u <App key>:<App secret>

/**
 * Retrieves a new, short-lived access token from Dropbox and stores it in ACCESS_TOKEN
 * @param    -
 * @return   bool:
 * @return   Error:
 */
fn get_new_access_token() -> Result<(), Error> {
    match ureq::post("https://api.dropbox.com/oauth2/token")
	// Auth requests use application/x-www-form-urlencoded POST parameters
	.send_form(&[
	    ("grant_type", "refresh_token"),
	    ("refresh_token", REFRESH_TOKEN),
	    ("client_id", APP_KEY),
	    ("client_secret", APP_SECRET)
	])
    {
	Ok(resp) => {
	    let json: NewAccessTokenMsg = resp
		.into_json()
		.expect("Couldn't serialise response into JSON");
	    println!("New Access Token (lifetime = {}s): {}", json.expires_in, json.access_token);
	    *ACCESS_TOKEN.write().unwrap() = json.access_token;
	    Ok(())
	},
	Err(UreqError::Status(code, resp)) => {
	    eprintln!("Error: {}", code);
	    eprintln!("Response: {:?}", resp);
	    Err(Error::new(ErrorKind::Other, "Couldn't retrieve new access token"))
	},
	Err(_) => {
	    eprintln!("some kind of io/transport error");
	    Err(Error::new(ErrorKind::Other, "Couldn't retrieve new access token"))
	}
    }
}

/**
 * Validates current access token
 * @return bool: true if the token is valid, false if it is invalid
 * @return Error: Problem with connection
 */
fn validate_access_token() -> Result<bool, Error> {
    match ureq::post("https://api.dropboxapi.com/2/check/user")
	.set("Authorization", &("Bearer ".to_owned() + &*ACCESS_TOKEN.read().unwrap()))
	.set("Content-Type", "application/json")
	.send_json( ureq::json!({ "query": "testSuccess" }) )
    {
	Ok(_) => {
	    // No need to check the json response as any 2XX HTTP response validates it (as per the docs)
	    return Ok(true)
	},
	Err(UreqError::Status(code, resp)) => {
	    eprintln!("Error: {}", code);
	    eprintln!("Response: {:?}", resp);
	    return Ok(false)
	},
	Err(_) => {
	    eprintln!("some kind of io/transport error");
	    Err(Error::new(ErrorKind::Other, "We done wrong"))
	}
    }
}


fn main() {
    get_new_access_token();
    println!("Access Token: {}", *ACCESS_TOKEN.read().unwrap());
    let message: &str = if let Ok(valid) = validate_access_token() {
	if valid {
	    "Token is validated!"
	} else {
	    "Token invalid. New token needed"
	}
    } else {
	"Unable to validate access token"
    };
    println!("{}", message);
}

/**
 * Revokes access token and refresh token
 */
fn _revoke_token() {
    let _ = ureq::post("https://api.dropboxapi.com/2/auth/token/revoke")
	.set("Authorization", &("Bearer ".to_owned() + &*ACCESS_TOKEN.read().unwrap()));
    println!("Token revoked");
}


/*
fn basic_request() {
let json_request_list_folders = ureq::json!({
    "include_deleted": false,
    "include_has_explicit_shared_members": true,
    "include_media_info": false,
    "include_mounted_folders": true,
    "include_non_downloadable_files": true,
    "path": "",
    "recursive": false
});

    let resp: Message = ureq::post("https://api.dropboxapi.com/2/files/list_folder")
	.set("Authorization", "Bearer sl.B0Bf2_UcF7aanNuVw6J7_1COQuCS-3b71Pb0SECHpGaAzyOsyenFV_6B5lAnygSxeTZO4zekOPtPh1eGHAzWEeYyMTbBrtz4auPbDbQ-tdMN77ScENhlmCX0bzFTyIjZsrUv1dlbBn3U")
	.set("Content-Type", "application/json")
	.send_json(json_request_list_folders)
	.expect("Couldn't create JSON from template")
	.into_json()
	.expect("Couldn't serialise response into JSON");

    for i in 0..resp.entries.len() {
        println!("{:?}", resp.entries[i].name);
//        println!("{:?}", resp["entries"][i]["name"]);
    }
}
*/
