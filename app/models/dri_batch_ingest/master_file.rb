class DriBatchIngest::MasterFile < Avalon::MasterFile
  scope :metadata, -> { where(metadata: true).take }

  def metadata?
    metadata == true
  end

  def preservation?
    preservation == true
  end
end
