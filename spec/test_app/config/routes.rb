Rails.application.routes.draw do

  mount DRIBatchIngest::Engine => "/dri_batch_ingest"
end
