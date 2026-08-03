mod client;
mod server;
mod fileop;
mod transfer;
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() > 2 {
        println!("Usage");
        println!("cargo run server");
        println!("Usage run client");
        return;
    }
      match args[1].as_str() {
        "server" => server::start_server(),
        "client" => client::start_client(),
        _ => println!("Unknown command"),
    }

}
