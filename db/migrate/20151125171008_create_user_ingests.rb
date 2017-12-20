class CreateUserIngests < ActiveRecord::Migration
  def change
    create_table :batch_ingest_user_ingests do |t|
      t.references :user, index: true

      t.timestamps null: false
    end

    add_foreign_key :batch_ingest_user_ingest, :user_group_users, column: :user_id
  end
end
