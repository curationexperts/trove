class CuratedCollectionsController < ApplicationController
  before_filter :build_collection, only: :create
  before_filter :load_collection, only: [:show, :append_to]
  authorize_resource

  def create
    if @curated_collection.save
      redirect_to (params[:return_url] || root_path)
    else
      render :new
    end
  end

  def show
  end

  def append_to
    record = ActiveFedora::Base.find(params[:pid])
    @curated_collection.members << record
    status = @curated_collection.save ? 'success' : 'error'
    render json: { status: status }
  end

end
