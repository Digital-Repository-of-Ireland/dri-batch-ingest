# frozen_string_literal: true
class DriBatchIngest::UserIngest < ActiveRecord::Base
  belongs_to :user

  has_many :batches, class_name: 'DriBatchIngest::IngestBatch'
end
