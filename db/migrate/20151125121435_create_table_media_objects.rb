class CreateTableMediaObjects < ActiveRecord::Migration
  def change
    create_table :batch_ingest_media_objects do |t|
      t.references :ingest_batch, index: true
      t.string :collection
      t.timestamps null: false
    end

    add_foreign_key :batch_ingest_media_objects, :batch_ingest_ingest_batches, column: :ingest_batch_id
  end
end
