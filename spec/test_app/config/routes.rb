Rails.application.routes.draw do

  mount DriBatchIngest::Engine => "/dri_batch_ingest"
end
