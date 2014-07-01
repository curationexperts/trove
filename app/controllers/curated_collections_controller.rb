class CuratedCollectionsController < ApplicationController
  load_and_authorize_resource only: [:show, :append_to]

  def create
    attributes = params.require(:curated_collection).permit(:title)
    attributes[:pid] = Sequence.next_val(name: 'curated_collection', format: 'uc.%d')
    @curated_collection = CuratedCollection.new(attributes.symbolize_keys)
    @curated_collection.managementType = (current_user.admin? ? "curated" : "personal")
    @curated_collection.apply_depositor_metadata(current_user)
    @curated_collection.read_groups = ['public']
    @curated_collection.displays = ['tdil']
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
