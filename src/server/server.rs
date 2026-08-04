
pub use std::net::TcpListener;
use std::thread;
use crate::fileop::handle_client;
pub fn start_server() {
    let listener = TcpListener::bind("0.0.0.0:9000").expect("Failed to bind");

    println!("Listening on 9000");

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                thread::spawn(move||handle_client(stream));
            }

            Err(e) => {
                println!("{}", e);
            }
        }
    }
}
