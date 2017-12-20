class DriBatchIngest::IngestBatch < Avalon::IngestBatch

  belongs_to :user_ingest
  has_many :media_objects, class_name: 'DriBatchIngest::MediaObject'

  def collection
    ActiveFedora::Base.find(self.collection_id, cast: true)
  end

  def finished_at
    media_objects.empty? ? '-' : media_objects.order(:created_at).last.finished_at
  end
  
end