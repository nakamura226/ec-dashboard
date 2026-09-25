class StoresController < ApplicationController
  before_action :set_store

  def sync
    @store.update!(status: "syncing")
    SyncEcDataJob.perform_later(@store.id)
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end
end
