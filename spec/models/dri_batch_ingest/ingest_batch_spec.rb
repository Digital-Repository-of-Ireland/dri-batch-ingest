require 'rails_helper'

describe DriBatchIngest::IngestBatch, type: :model do

  describe "Associations" do
    it { should belong_to(:user_ingest) }
    it { should have_many(:media_objects) }
  end

  describe 'methods' do

    before(:each) do
      mf = DriBatchIngest::MasterFile.new
      @mf2 = DriBatchIngest::MasterFile.new
      mf.status_code = 'COMPLETED'
      @mf2.status_code = 'PENDING'

      @mo = DriBatchIngest::MediaObject.create
      @mo.parts << mf
      @mo.parts << @mf2
    end

    it 'should be finished if all media objects are finished' do
      ib = described_class.new
      ib.media_objects << @mo
      expect(ib.finished?).to be false

      @mf2.status_code = 'COMPLETED'
      @mf2.save
      expect(ib.finished?).to be true
    end

    it 'should be finished at the time of the last media object' do
      ib = described_class.new
      ib.media_objects << @mo
      ib.save

      @mf2.status_code = 'COMPLETED'
      @mf2.save

      expect(ib.finished_at).to eq @mo.finished_at
    end
  end
end
