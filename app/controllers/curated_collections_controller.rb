class CuratedCollectionsController < ApplicationController
  include Blacklight::Catalog::SearchContext
  load_and_authorize_resource instance_name: :curated_collection

  def create
    @curated_collection.attributes = collection_params
    @curated_collection.read_groups = ['public']
    @curated_collection.displays = ['tdil']
    @curated_collection.apply_depositor_metadata(current_user)
    @curated_collection.creator = [current_user.user_key]
    if @curated_collection.save
      redirect_to (params[:return_url] || root_path)
    else
      render :new
    end
  end

  def update
    if members = params[controller_name.singularize].delete(:members)
      members = members.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if members.is_a? Hash
      member_ids = members.sort_by { |e| e[:weight] }.map { |e| e[:id] } 
      @curated_collection.member_ids = member_ids 
    end
    if @curated_collection.save
      redirect_to @curated_collection 
    end
  end

  def edit
    initialize_fields
  end

  def show
  end

  def new
    initialize_fields
  end

  def destroy
    @curated_collection.destroy
    redirect_to root_path
  end

  def append_to
    record = ActiveFedora::Base.find(params[:pid])
    @curated_collection.members << record
    status = @curated_collection.save ? 'success' : 'error'
    render json: { status: status }
  end

protected
  def initialize_fields
    %w(description).each do |key|
      # if value is empty, we create an one element array to loop over for output 
      @curated_collection[key] = [''] if @curated_collection[key].empty?
    end
  end

  def collection_params
    params.require(controller_name.singularize).permit(:title)
  end

end
