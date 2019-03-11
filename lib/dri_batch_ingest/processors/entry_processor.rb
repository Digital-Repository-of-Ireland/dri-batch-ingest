# frozen_string_literal: true
require 'avalon/batch'
require 'json'

module DriBatchIngest
  module Processors
    class EntryProcessor < Avalon::Batch::Entry
      def media_object
        @media_object ||= DriBatchIngest::MediaObject.new(collection: @manifest.package.collection)
      end

      def process!(opts = {})
        batch = DriBatchIngest::IngestBatch.find(opts['batch'])
        user = User.find(batch.user_ingest.user_id)

        media_object.ingest_batch = batch
        media_object.save

        @files.each do |file_spec|
          master_file = DriBatchIngest::MasterFile.new
          master_file.media_object = media_object
          master_file.metadata = true if file_spec.key?(:label) && file_spec[:label] == 'metadata'
          master_file.preservation = true if file_spec.key?(:label) && file_spec[:label] == 'preservation'
          master_file.save

          spec = download_spec(user, file_spec[:file], opts)
          master_file.download_spec = spec.to_json

          master_file.file_size = spec['file_size'] if spec.key?('file_size')
          master_file.file_location = file_spec['file']
          master_file.status_code = 'PENDING'

          media_object.save if master_file.save
        end

        media_object
      end

      private

        def download_spec(user, file_path, opts)
          path = Pathname.new(file_path)
          (url, extra) = provider_file_info(user, path, opts)

          result = { 'url' => url }
          result.merge!(extra.stringify_keys) unless extra.nil?
          result['expires'] = result['expires'].iso8601 if result.key?('expires')

          result
        end

        def provider_file_info(user, file_path, opts)
          url_options = BrowseEverything.config
          if url_options['sandbox_file_system'].present?
            url_options['sandbox_file_system'][:current_user] = user.email
          end

          browser = BrowseEverything::Browser.new(url_options)
          browser.providers.values.each do |p|
            p.token = opts["#{p.key}_token"]
          end

          if opts['provider'] == 'sandbox_file_system'
            file_path = File.join(browser.providers['sandbox_file_system'].home, file_path)
          end

          browser.providers[opts['provider']].link_for(file_path.to_s)
        end
    end
  end
end
