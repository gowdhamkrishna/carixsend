use crate::transfer::Chunk;

use std::fs::File;
use std::io::Write;
use std::net::TcpStream;
use std::os::unix::fs::FileExt;

pub fn perform_chunk_transfer(
    stream: &mut TcpStream,
    file: &File,
    file_name: &str,
    total_size: u64,
    chunk: &Chunk,
) {

    // filename length
    let len = file_name.len() as u16;
    stream.write_all(&len.to_be_bytes()).unwrap();

    // filename
    stream.write_all(file_name.as_bytes()).unwrap();

    // total file size
    stream.write_all(&total_size.to_be_bytes()).unwrap();

    // offset
    stream.write_all(&chunk.offset.to_be_bytes()).unwrap();

    // chunk length
    stream.write_all(&chunk.length.to_be_bytes()).unwrap();

    let mut remaining = chunk.length;
    let mut position = chunk.offset;

    let mut buffer = vec![0u8; 128 * 1024];

    while remaining > 0 {

        let read_size =
            remaining.min(buffer.len() as u64)
                as usize;

        let bytes = file
            .read_at(
                &mut buffer[..read_size],
                position,
            )
            .unwrap();

        if bytes == 0 {
            break;
        }

        stream
            .write_all(&buffer[..bytes])
            .unwrap();

        position += bytes as u64;

        remaining -= bytes as u64;
    }

    println!(
        "Finished chunk offset={}",
        chunk.offset
    );
}