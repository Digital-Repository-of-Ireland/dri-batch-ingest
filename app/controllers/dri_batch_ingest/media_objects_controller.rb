# frozen_string_literal: true
require 'filesize'

class DriBatchIngest::MediaObjectsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :authenticate_user!

  def show
    @batch = DriBatchIngest::IngestBatch.find(params[:id])
    @media_object = DriBatchIngest::MediaObject.find(params[:media_id])

    @files = @media_object.parts.page params[:page]

    @file_info = {}
    @files.each do |f|
      info = {}
      ds = JSON.parse(f['download_spec'])
      info[:title] = ds['file_name']
      info[:size] = ::Filesize.from("#{f.file_size} B").pretty
      info[:url] = ds['url']
      @file_info[f.id] = info
    end
  end
end
