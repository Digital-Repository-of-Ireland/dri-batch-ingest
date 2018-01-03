module DriBatchIngest
  class MediaObject < ActiveRecord::Base
    belongs_to :ingest_batch, class_name: 'DriBatchIngest::IngestBatch'
    has_many :parts, class_name: 'DriBatchIngest::MasterFile'

    scope :status, ->(status) {
      joins(:parts).where('dri_batch_ingest_master_files.status_code' => status).distinct
    }

    scope :pending, -> {
      joins(:parts).where('dri_batch_ingest_master_files.status_code' => 'PENDING').distinct
    }

    scope :excluding_failed, -> {
      where(['dri_batch_ingest_media_objects.id NOT IN (?)', DriBatchIngest::MediaObject.status('FAILED').pluck(:id)]) if failed.any?
    }

    scope :failed, -> {
       DriBatchIngest::MediaObject.status('FAILED')
    }

    scope :completed, -> {
       DriBatchIngest::MediaObject.status('COMPLETED')
    }

    def destroy
      parts.each(&:destroy)
      parts.clear
      super
    end

    def metadata
      parts.all.metadata
    end

    def finished_processing?
      parts.all?{ |master_file| master_file.finished_processing? }
    end

    def finished_at
      parts.order(:updated_at).last.updated_at
    end

    def succeeded?
      parts.all?{ |master_file| master_file.succeeded? }
    end

    def failed?
      parts.any? { |master_file| master_file.failed? }
    end
  end
end
