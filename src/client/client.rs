use crate::fileop::perform_chunk_transfer;
use crate::transfer::split_into_blocks;

use std::fs::File;
use std::net::TcpStream;
use std::sync::Arc;
use std::thread;

pub fn start_client() {

    let file_name = "movie.mp4";

    // Open file once
    let file = Arc::new(
        File::open(file_name)
            .expect("Cannot open file")
    );

    // File size
    let file_size =
        file.metadata()
            .unwrap()
            .len();

    // 4MB chunk size
    let chunk_size = 4 * 1024 * 1024;

    // Split file
    let chunks =
        split_into_blocks(
            file_size,
            chunk_size,
        );

    println!(
        "File Size : {}",
        file_size
    );

    println!(
        "Chunks : {}",
        chunks.len()
    );

    let mut handles = Vec::new();

    for chunk in chunks {

        let file =
            Arc::clone(&file);

        let filename =
            file_name.to_string();

        handles.push(
            thread::spawn(move || {

                let stream =
                    TcpStream::connect(
                        "127.0.0.1:9000"
                    )
                    .unwrap();

                perform_chunk_transfer(
                    stream,
                    file,
                    filename,
                    chunk,
                );

            })
        );
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Transfer Complete");
}