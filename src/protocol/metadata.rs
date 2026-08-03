#[derive(Debug, Clone)]
pub struct TransferMetadata {
    pub transfer_id: u64,
    pub filename: String,
    pub file_size: u64,
    pub chunk_size: u64,
    pub chunk_count: u32,
}   