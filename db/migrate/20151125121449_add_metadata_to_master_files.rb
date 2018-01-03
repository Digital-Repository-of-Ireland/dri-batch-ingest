class AddMetadataToMasterFiles < ActiveRecord::Migration
  def change
    add_column :dri_batch_ingest_master_files, :metadata, :boolean
  end
end
