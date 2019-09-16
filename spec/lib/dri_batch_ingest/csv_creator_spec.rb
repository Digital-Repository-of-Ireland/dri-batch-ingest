require 'rails_helper'
require 'csv'
require 'dri_batch_ingest/csv_creator'

describe DriBatchIngest::CsvCreator do

  it 'should create a csv from files' do
    base_dir = File.join(file_fixture_path, 'ingest')

    creator = described_class.new(
      base_dir,
      'user@example.com',
      'test1',
      'metadata',
      'data',
      'preservation')

    creator.create
    manifest = CSV.read(creator.csv_file)

    expect(manifest.length).to eq 4
    expect(manifest[1].length).to eq 9
    expect(manifest[-2][3..-1]).to contain_exactly(
      "metadata/object1.xml",
      "metadata",
      "data/object1.jpeg",
      "asset",
      "preservation/object1.jpeg",
      "preservation"
      )
    expect(manifest[-1][3..-1]).to contain_exactly(
      "metadata/object2.xml",
      "metadata",
      "data/object2.jpeg",
      "asset",
      "preservation/object2.jpeg",
      "preservation"
      )

    File.unlink(creator.csv_file)
  end
end
