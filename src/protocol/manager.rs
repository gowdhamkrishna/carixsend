use super::metadata::TransferMetadata;

pub struct TransferManager {
    current: Option<TransferMetadata>,
}
impl TransferManager {
    pub fn new() -> Self {
        Self { current: None }
    }
    pub fn start_transfer(&mut self, meta: TransferMetadata) {
        println!("Starting transfer:");
        println!("{:#?}", meta);

        self.current = Some(meta);
    }

    pub fn current(&self) -> Option<&TransferMetadata> {
        self.current.as_ref()
    }
}
