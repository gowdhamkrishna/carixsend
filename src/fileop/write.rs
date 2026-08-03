use std::fs::{ OpenOptions};
use std::io::{Read};
use std::net::TcpStream;
use std::os::unix::fs::FileExt;

pub fn handle_client(mut stream: TcpStream) {
    // 1)FileName - NameLength -Name
    // 2)Offset
    // 3)Chunk Length

    // FileName
    let mut name_len = [0u8; 2];
    stream.read_exact(&mut name_len).unwrap();
    let name_len = u16::from_be_bytes(name_len);

    let mut file_name = vec![0u8; name_len as usize];
    stream.read_exact(&mut file_name).unwrap();
    let file_name = String::from_utf8(file_name).unwrap();

    // Offset

    let mut offset = [0u8; 8];
    stream.read_exact(&mut offset).unwrap();
    let offset = u64::from_be_bytes(offset);

    // Chunk Length

    let mut chunk_length = [0u8; 8];
    stream.read_exact(&mut chunk_length).unwrap();
    let chunk_length = u64::from_be_bytes(chunk_length);

    let file = OpenOptions::new()
        .create(true)
        .write(true)
        .read(true)
        .open(format!("received_{}", file_name))
        .unwrap();
    let mut received = 0u64;
    let mut buffer = [0u8; 8192];

    while received < chunk_length {
        let remaining = (chunk_length - received) as usize;
        let max_read = std::cmp::min(remaining as usize, buffer.len());
        let size = stream.read(&mut buffer[..max_read]).unwrap();
        if size == 0 {
            break;
        }
        file.write_at(
            &buffer[..size],
            offset+received
        ).unwrap();
        received+=size as u64;

    }
}
