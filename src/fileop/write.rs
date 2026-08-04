use std::fs::{ OpenOptions};
use std::io::{Read};
use std::net::TcpStream;
use std::os::unix::fs::FileExt;

pub fn handle_client(mut stream: TcpStream) {
    stream.set_nodelay(true).ok();
    let mut buffer = vec![0u8; 128 * 1024];

    loop {
        // 1) FileName Length
        let mut name_len = [0u8; 2];
        if stream.read_exact(&mut name_len).is_err() {
            break;
        }
        let name_len = u16::from_be_bytes(name_len);

        // 2) FileName
        let mut file_name = vec![0u8; name_len as usize];
        if stream.read_exact(&mut file_name).is_err() {
            break;
        }
        let file_name = String::from_utf8(file_name).unwrap();

        // 3) Total File Size
        let mut total_size = [0u8; 8];
        if stream.read_exact(&mut total_size).is_err() {
            break;
        }
        let total_size = u64::from_be_bytes(total_size);

        // 4) Offset
        let mut offset = [0u8; 8];
        if stream.read_exact(&mut offset).is_err() {
            break;
        }
        let offset = u64::from_be_bytes(offset);

        // 5) Chunk Length
        let mut chunk_length = [0u8; 8];
        if stream.read_exact(&mut chunk_length).is_err() {
            break;
        }
        let chunk_length = u64::from_be_bytes(chunk_length);

        let file = OpenOptions::new()
            .create(true)
            .write(true)
            .read(true)
            .open(format!("received_{}", file_name))
            .unwrap();

        // Pre-allocate the file size immediately if it is not already initialized
        if file.metadata().map(|m| m.len()).unwrap_or(0) < total_size {
            file.set_len(total_size).ok();
        }

        let mut received = 0u64;

        while received < chunk_length {
            let remaining = (chunk_length - received) as usize;
            let max_read = std::cmp::min(remaining, buffer.len());
            let size = match stream.read(&mut buffer[..max_read]) {
                Ok(0) => break,
                Ok(s) => s,
                Err(_) => break,
            };
            file.write_at(
                &buffer[..size],
                offset + received
            ).unwrap();
            received += size as u64;
        }

        if received < chunk_length {
            break;
        }
    }
}

