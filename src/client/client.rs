use crate::fileop::perform_chunk_transfer;
use crate::transfer::split_into_blocks;

use std::fs::File;
use std::net::TcpStream;
use std::sync::Arc;
use std::thread;

pub fn start_client() {

    let file_name = "file.txt";

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

    let chunks = Arc::new(chunks);
    let num_workers = 4;
    let chunks_per_worker = if chunks.is_empty() { 1 } else { (chunks.len() + num_workers - 1) / num_workers };

    let mut handles = Vec::new();

    for worker_id in 0..num_workers {
        let file = Arc::clone(&file);
        let filename = file_name.to_string();
        let chunks = Arc::clone(&chunks);

        handles.push(thread::spawn(move || {
            let start_idx = worker_id * chunks_per_worker;
            if start_idx >= chunks.len() {
                return;
            }
            let end_idx = std::cmp::min(start_idx + chunks_per_worker, chunks.len());
            let worker_chunks = &chunks[start_idx..end_idx];

            let mut stream = TcpStream::connect("127.0.0.1:9000").expect("Cannot connect to server");
            stream.set_nodelay(true).ok();

            for chunk in worker_chunks {
                perform_chunk_transfer(
                    &mut stream,
                    &file,
                    &filename,
                    file_size,
                    chunk,
                );
            }
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Transfer Complete");
}