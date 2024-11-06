DRIBatchIngest::Engine.routes.draw do

  get '/', to: "ingest#new"

  get 'batch', to: 'ingest#new', as: :new_batch
  get 'batch/:id', to: 'ingest#show', as: :batch
  post 'batch', to: 'ingest#create', as: :batch_ingest
  put 'batch/:id', to: 'ingest#update', as: :update_batch  

  get 'batch/:id/media/:media_id', to: 'media_objects#show', as: :media_object

  get 'ingests', to: 'user_ingests#index', as: :ingests

  put 'media/:id/files/:file_id', to: 'master_files#update'
      
  mount BrowseEverything::Engine => '/browse'
end
