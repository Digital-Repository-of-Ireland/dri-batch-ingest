module DriBatchIngest
  class IngestBatch < ActiveRecord::Base
    belongs_to :user_ingest, class_name: 'DriBatchIngest::UserIngest'
    has_many :media_objects, class_name: 'DriBatchIngest::MediaObject'

    def collection
      ActiveFedora::Base.find(self.collection_id, cast: true)
    end

    def finished?
      media_objects.all?{ |m| m.finished_processing? }
    end

    def finished_at
      media_objects.empty? ? '-' : media_objects.order(:created_at).last.finished_at
    end
  
  end
end