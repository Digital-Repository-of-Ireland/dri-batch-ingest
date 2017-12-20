require 'avalon/batch'
require 'rest-client'

class DriBatchIngest::ProcessBatch
  @queue = :process_batch
  
  def self.perform(batch_id, media_object_ids = nil)
    batch = DriBatchIngest::IngestBatch.find(batch_id)
    user = User.find(batch.user_ingest.user_id)
    user_email = user.email
    user_token = user.authentication_token

    media_objects = media_object_ids || batch.media_objects

    media_objects.each do |mo|
      media_object = mo.is_a?(Avalon::MediaObject) ? mo : MediaObject.find(mo)
      ingest_message = process_media_object(media_object, user_email, batch.collection_id)
      
      send_message(post_url(batch.collection_id, user_email, user_token), ingest_message)
    end
  end

  def self.label_file(master_file)
    master_file.preservation? ? 'preservation' : 'asset'
  end

  def self.metadata_info(id, metadata)
    metadata_info = {}
    metadata_info['id'] = metadata.id
    metadata_info['callback_url'] = "#{Settings.callback.base}/media/#{id}/files/#{metadata.id}"
    metadata_info['label'] = 'metadata'

    if metadata.status_code == 'COMPLETED'
      metadata_info['object_id'] = URI(metadata.file_location).path.split('/').last
    else
      metadata_info['download_spec'] = JSON.parse(metadata.download_spec)
    end

    metadata_info
  end

  def self.process_media_object(mo, email, collection_id)
    ingest_message = {}
    ingest_message['user'] = email
    ingest_message['collection'] = collection_id
    ingest_message['media_object'] = mo.id
    ingest_message['metadata'] = metadata_info(mo.id, mo.parts.metadata)

    ingest_message['files'] = []
    mo.parts.each do |mf|
      next if mf.metadata? || mf.status_code == 'COMPLETED'

      master_file = {}
      master_file['id'] = mf.id
      master_file['callback_url'] = "#{Settings.callback.base}/media/#{mo.id}/files/#{mf.id}"
      master_file['label'] = label_file(mf)

      master_file['download_spec'] = JSON.parse(mf.download_spec)
      ingest_message['files'] << master_file
    end

    ingest_message
  end

  def self.post_url(collection_id, user_email, user_token)
    "#{Settings.dri.endpoint}/collections/#{collection_id}/batch?user_email=#{user_email}&user_token=#{user_token}"
  end

  def self.send_message(url, ingest_message)
    RestClient.post url, { 'batch_ingest' => ingest_message.to_json }, content_type: :json, accept: :json
  end
end