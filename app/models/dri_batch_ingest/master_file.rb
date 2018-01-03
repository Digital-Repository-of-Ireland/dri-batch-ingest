module DriBatchIngest
  class MasterFile < ActiveRecord::Base
    belongs_to :media_object, class_name: 'DriBatchIngest::MediaObject'

    END_STATES = ['CANCELLED', 'COMPLETED', 'FAILED']

    scope :metadata, -> { where(metadata: true).take }

    def metadata?
      metadata == true
    end

    def preservation?
      preservation == true
    end

    def process file=nil
      raise "MasterFile is already being processed" if status_code.present? && !finished_processing?
    end

    def status?(value)
      status_code == value
    end

    def failed?
      status?('FAILED')
    end

    def succeeded?
      status?('COMPLETED')
    end

    def finished_processing?
      END_STATES.include?(status_code)
    end
  end
end
