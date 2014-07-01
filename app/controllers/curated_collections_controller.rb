class CuratedCollectionsController < ApplicationController
  before_filter :build_collection, only: :create
  before_filter :load_collection, only: [:show, :append_to]
  authorize_resource :curated_collection, parent: false

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

protected

  def load_collection
    @curated_collection = model_class.find(params[:id])
  end

  def build_collection
    attributes = params.require(:curated_collection).permit(:title)
    @curated_collection = model_class.new(attributes.symbolize_keys)
    @curated_collection.read_groups = ['public']
    @curated_collection.displays = ['tdil']
    @curated_collection.apply_depositor_metadata(current_user)
  end

end
