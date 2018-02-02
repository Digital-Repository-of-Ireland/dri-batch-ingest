require 'dri_batch_ingest/csv_creator'
require 'avalon/batch'
require 'dri_batch_ingest/processors'

class DriBatchIngest::CreateManifest
  @queue = :create_manifest
  
  def self.perform(ingest_id, base_dir, email, collection, metadata_path, asset_path, preservation_path)
    creator = DriBatchIngest::CsvCreator.new(
      base_dir,
      email,
      collection,
      metadata_path,
      asset_path,
      preservation_path
    )
    creator.create

    package = Avalon::Batch::Package.new(
        creator.csv_file,
        collection,
        DriBatchIngest::Processors::EntryProcessor
      )

    ingest = DriBatchIngest::UserIngest.find(ingest_id)
    batch = DriBatchIngest::IngestBatch.create(collection_id: collection, email: package.manifest.email, user_ingest_id: ingest.id)

    media_objects = package.process!({ 'batch' => batch.id, 'provider' => 'file_system', 
      'file_system_token' => nil})
      
    ingest.batches << batch

    Resque.enqueue(DriBatchIngest::ProcessBatch, batch.id)
    ingest.save
  end
end
