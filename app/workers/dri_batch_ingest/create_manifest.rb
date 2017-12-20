require 'dri_batch_ingest/csv_creator'

class DriBatchIngest::CreateManifest
  @queue = :create_manifest
  
  def self.perform(ingest_id, base_dir, email, collection, metadata_path, asset_path, preservation_path)
    creator = CsvCreator.new(
      base_dir,
      email,
      collection,
      metadata_path,
      asset_path,
      preservation_path
    )
    creator.create

    Resque.enqueue(ProcessManifest, ingest_id, collection, selected_file(base_dir, creator.csv_file), { 'file_system_token' => nil })
  end

  private

  def self.selected_file(ingest_dir, manifest_file)
    full_path = File.expand_path(File.join(ingest_dir, manifest_file))
    file_size = File.size(full_path).to_i rescue 0
    file_name = File.basename(full_path)

    {"0" => {
        "url"=>"file://#{full_path}",
        "provider"=>"file_system",
        "file_name"=>file_name, "file_size"=>"#{file_size}"
      }
    }
  end

end