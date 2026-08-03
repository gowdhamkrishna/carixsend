use super::packet::Chunk;

pub fn split_into_blocks(
    filesize: u64,
    chunk_size: u64,
) -> Vec<Chunk> {

    let mut chunks = Vec::new();

    let mut offset = 0;

    while offset < filesize {

        let remaining = filesize - offset;

        let length = remaining.min(chunk_size);

        chunks.push(Chunk {
            offset,
            length,
        });

        offset += length;
    }

    chunks
}