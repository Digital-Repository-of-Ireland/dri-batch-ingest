# frozen_string_literal: true
class DriBatchIngest::UserIngestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @ingests = DriBatchIngest::UserIngest.where(user_id: current_user.id).order(created_at: :desc).page(params[:page]).per(10)
    @batches = user_batches
  end

  def show; end

  private

  def user_batches
    batches = {}

    @ingests.each do |i|
      next unless i.batches.first
      batch = i.batches.first

      batches[batch.id] = {
        total: batch.media_objects.count,
        pending: batch.media_objects.excluding_failed.pending.count,
        completed: batch.media_objects.completed.count,
        failed: batch.media_objects.failed.count
      }
    end

    batches
  end
end
