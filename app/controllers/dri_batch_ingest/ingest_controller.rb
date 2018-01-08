require 'avalon/batch'
require 'dri_batch_ingest/processors/entry_processor'
require 'dri_batch_ingest/csv_creator'

class DriBatchIngest::IngestController < ApplicationController
  before_action :authenticate_user!

  def base_dir
    @base_dir || set_base_dir
  end

  def index
  end

  def new
    @collections = user_collections
    Dir.chdir(base_dir){ @user_dirs = directory_hash('.')[:children] }
  end

  def show
    @batch = DriBatchIngest::IngestBatch.find(params[:id])

    @media_objects = if params[:status]
                       @batch.media_objects.status(params[:status]).page params[:page]
                     else 
                       @batch.media_objects.page params[:page]
                     end
  end

  def create
    collection = params[:collection]
    ingest = DriBatchIngest::UserIngest.create(user_id: current_user.id)

    if params[:type].present? && params[:type] == 'manifest'
      Resque.enqueue(DriBatchIngest::ProcessManifest, ingest.id, collection, params['selected_files'], provider_tokens)
    else
      metadata_path = params[:metadata_path]
      asset_path = params[:asset_path]
      preservation_path = params[:preservation_path]
          
      Resque.enqueue(DriBatchIngest::CreateManifest, ingest.id, base_dir, current_user.email, collection, metadata_path, asset_path, preservation_path)
    end
    
    redirect_to ingests_url(ingest)
  end

  def update
    @batch = DriBatchIngest::IngestBatch.find(params[:id])

    media_object_ids = @batch.media_objects.status('FAILED').pluck(:id)
    Resque.enqueue(DriBatchIngest::ProcessBatch, @batch.id, media_object_ids)
  
    redirect_to ingests_url
  end

  private
 
  def user_collections
    query = "_query_:\"{!join from=id to=ancestor_id_sim}manager_access_person_ssim:#{current_user.email}\""
    query += " OR manager_access_person_ssim:#{current_user.email}"

    fq = ["+#{ActiveFedora.index_field_mapper.solr_name('is_collection', :facetable, type: :string)}:true"]
    
    if params[:governing].present?
      fq << "+#{ActiveFedora.index_field_mapper.solr_name('isGovernedBy', :stored_searchable, type: :symbol)}:#{params[:governing]}"
    end
    
    solr_query = Solr::Query.new(query, 100, { fq: fq })
    solr_query.map do |document| 
      [
        document[
        ActiveFedora.index_field_mapper.solr_name(
             'title', :stored_searchable, type: :string
        )].first,
        document.id
      ]
    end
  end

  def directory_hash(path, name=nil, exclude = [])                                
    exclude.concat(['..', '.', '.git', '__MACOSX', '.DS_Store'])
    key = (name || path)              
    data = { name: key, type: 'folder', path: path }                                             
    data[:children] = []                                               
    Dir.foreach(path) do |entry|                                                  
      next if exclude.include?(entry)   
      full_path = path == '.' ? entry : File.join(path, entry)

      if File.directory?(full_path)                                               
        data[:children] << directory_hash(full_path, entry)                              
      end                                                                         
    end                                                                           
  
    data                                                                   
  end

  def provider_tokens
    tokens = {}
    browser = BrowseEverything::Browser.new
    browser.providers.values.each do |p|
      tokens["#{p.key}_token"] = session["#{p.key}_token"] if session["#{p.key}_token"].present?
    end

    tokens
  end

  def set_base_dir
    url_options = BrowseEverything.config
    if url_options['file_system'].present?
      url_options['file_system'][:current_user] = current_user.email
    end
    browser = BrowseEverything::Browser.new(url_options)
    browser.providers['file_system'].home
  end

end
