use std::io::{Read, Write};
use std::net::TcpStream;

pub fn send_u16(stream:&mut TcpStream,value:u16){
    stream.write_all(&value.to_be_bytes()).unwrap();
}
pub fn send_u32(stream:&mut TcpStream,value:u32){
    stream.write_all(&value.to_be_bytes()).unwrap();
}
pub fn send_u64(stream:&mut TcpStream,value:u64){
    stream.write_all(&value.to_be_bytes()).unwrap();
}
pub fn receive_u16(stream: &mut TcpStream) -> std::io::Result<u16> {
    let mut buff = [0u8; 2];
    stream.read_exact(&mut buff)?;
    Ok(u16::from_be_bytes(buff))
}
pub fn receive_u32(stream: &mut TcpStream) -> std::io::Result<u32> {
    let mut buff = [0u8; 4];
    stream.read_exact(&mut buff)?;
    Ok(u32::from_be_bytes(buff))
}
pub fn receive_u64(stream: &mut TcpStream) -> std::io::Result<u64> {
    let mut buff = [0u8; 8];
    stream.read_exact(&mut buff)?;
    Ok(u64::from_be_bytes(buff))
}
