require 'rails_helper'
require 'resque'
require 'dri_batch_ingest/processors'

describe DriBatchIngest::ProcessBatch do

  let(:user) { FactoryBot.create(:collection_manager) }
  let(:user_ingest) { DriBatchIngest::UserIngest.new }

  it 'should create manifest and start process batch' do
    stub_const 'ProcessBatchIngest', Class.new
    collection = 'test1'

    package = Avalon::Batch::Package.new(
      file_fixture('manifest.csv').to_s,
      collection,
      DriBatchIngest::Processors::EntryProcessor
    )

    user_ingest.user_id = user.id
    user_ingest.save

    batch = DriBatchIngest::IngestBatch.create(
              collection_id: collection,
              email: user.email,
              user_ingest_id: user_ingest.id
            )

    package.process!(
      'batch' => batch.id,
      'provider' => 'sandbox_file_system',
      'file_system_token' => nil
    )

    user_ingest.batches << batch
    user_ingest.save

    expect(Resque).to receive(:enqueue).twice
    described_class.perform(batch.id)

    user_ingest.destroy
  end
end
