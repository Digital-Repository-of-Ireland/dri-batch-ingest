# frozen_string_literal: true
class DriBatchIngest::UserIngestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @ingests = DriBatchIngest::UserIngest.where(user_id: current_user.id).order(created_at: :desc).page(params[:page]).per(10)
    @batches = {}

    @ingests.each do |i|
      next unless i.batches.first
      batch = i.batches.first

      total = batch.media_objects.count
      pending = batch.media_objects.excluding_failed.pending.count
      failed = batch.media_objects.failed.count
      completed = batch.media_objects.completed.count

      counts = {
        total: total,
        pending: pending,
        completed: completed,
        failed: failed
      }
      @batches[batch.id] = counts
    end
  end

  def show; end
end
