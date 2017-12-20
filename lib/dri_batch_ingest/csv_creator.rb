require "csv"

class DriBatchIngest::CsvCreator

  def initialize(base_dir, user_email, collection, metadata_path, asset_path=nil, preservation_path=nil)
    @user_email = user_email
    @base_dir = base_dir

    ingest_name = "#{collection}-#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}"
    @csv_file = "#{ingest_name}.csv"
    @header = [ ingest_name, @user_email ]

    @metadata_path = metadata_path
    @asset_path = asset_path
    @preservation_path = preservation_path
  end

  def csv_file
    @csv_file
  end

  def create
    Dir.chdir(@base_dir) do
      metadata, assets, preservation = files_to_import
      to_csv(metadata, assets, preservation)
    end
  end

  def files_to_import
    metadata = {}
    assets = {}
    preservation = {}

    asset_row_length = 0
    preservation_row_length = 0

    # Get the metadata
    Dir.entries(@metadata_path).each do |mfile|
      next unless File.file?(File.join(@metadata_path, mfile))

      ext = File.extname(mfile)
      basename = File.basename(mfile, ext)
      if ext == ".xml"
        metadata[basename.to_sym] = File.join(@metadata_path, mfile)

        # Does it have any corresponding data files?
        unless @asset_path.nil?
          tmp = Dir.glob(["#{@asset_path}/#{basename}.*","#{@asset_path}/#{basename}_[0-9]*.*"])
          if tmp.count > 0
            assets[basename.to_sym] = tmp
            asset_row_length = tmp.length if tmp.length > asset_row_length
          end
        end
        
        # Does it have any corresponding preservation-only data files?
        unless @preservation_path.nil?
          tmp = Dir.glob(["#{@preservation_path}/#{basename}.*","#{@preservation_path}/#{basename}_[0-9]*.*"])
          if tmp.count > 0
            preservation[basename.to_sym] = tmp
            preservation_row_length = tmp.length if tmp.length > preservation_row_length
          end
        end
      end
    end

    @row_length = asset_row_length + preservation_row_length
    [metadata,assets,preservation]
  end

  def to_csv(metadata, assets, preservation)
    title_row = [ 'Title', 'Creator', 'Date Issued' ]
    (0..@row_length).each do |_i|
      title_row.concat(['File', 'Label'])
    end

    CSV.open(@csv_file, "w") do |csv|
      csv << @header
      csv << title_row

      metadata.each do |key, m|
        row = [ key, @user_email, Time.now, m, 'metadata' ]
        
        asset_list = assets.key?(key) ? assets[key] : []
        preservation_list = preservation.key?(key) ? preservation[key] : []

        asset_list.each { |a| row.concat([a, 'asset']) }
        preservation_list.each { |p| row.concat([p, 'preservation']) }

        csv << row
      end
    end
  end

end