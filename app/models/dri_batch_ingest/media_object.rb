class DriBatchIngest::MediaObject < Avalon::MediaObject

  belongs_to :ingest_batch, class_name: 'DriBatchIngest::IngestBatch'
  has_many :parts, class_name: 'DriBatchIngest::MasterFile'

  scope :status, ->(status) {
    joins(:parts).where('master_files.status_code' => status).distinct
  }

  scope :pending, -> {
    joins(:parts).where('master_files.status_code' => 'PENDING').distinct
  }

  scope :excluding_failed, -> {
    where(['media_objects.id NOT IN (?)', DriBatchIngest::MediaObject.status('FAILED').pluck(:id)]) if failed.any?
  }

  scope :failed, -> {
     DriBatchIngest::MediaObject.status('FAILED')
  }

  scope :completed, -> {
     DriBatchIngest::MediaObject.status('COMPLETED')
  }

  def metadata
    parts.all.metadata
  end

  def finished_at
    parts.order(:updated_at).last.updated_at
  end
end
