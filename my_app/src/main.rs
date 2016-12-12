#[macro_use]
extern crate nickel;
extern crate serde_json;

use nickel::Nickel;
use serde_json::Value;
use std::fs::File;
use std::path::Path;
use std::io::Read;

fn main() {
    let config_path = Path::new("../config/my_app.json");
    let mut config_file = match File::open(&config_path) {
        Ok(file) => file,
        Err(_) => panic!("Couldn't open config file!"),
    };

    let mut config_string = String::new();
    config_file.read_to_string(&mut config_string).unwrap();

    let config: Value = serde_json::from_str(&config_string[..]).unwrap();
    let greeting = config.as_object().unwrap().get("greeting").unwrap().clone();

    let mut server = Nickel::new();

    server.utilize(router! {
        get "**" => |_req, _res| {
            format!("{}", greeting)
        }
    });

    server.listen("0.0.0.0:8080");
}
