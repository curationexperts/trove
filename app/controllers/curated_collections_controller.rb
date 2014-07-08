class CuratedCollectionsController < ApplicationController
  include Blacklight::Catalog::SearchContext
  load_and_authorize_resource instance_name: :curated_collection

  def create
    @curated_collection.attributes = collection_params.except(:members)
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
    if members = collection_params[:members]
      members = members.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if members.is_a? Hash
      member_ids = members.sort_by { |e| e[:weight] }.map { |e| e[:id] } 
      @curated_collection.member_ids = member_ids 
    end
    if collection_params[:type].present?
      # we're changing the type of collection this is
      @curated_collection.clear_relationship(:has_model)
      @curated_collection.add_relationship(:has_model, class_uri(collection_params[:type]))
    end
    @curated_collection.attributes = collection_params.except(:members)
    if @curated_collection.save
      redirect_to curated_collection_path(@curated_collection)
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

  def remove_from
    @curated_collection.delete_member_at(params[:position].to_i)
    @curated_collection.save!
    redirect_to @curated_collection
  end

protected
  def initialize_fields
    %w(description).each do |key|
      # if value is empty, we create an one element array to loop over for output 
      @curated_collection[key] = [''] if @curated_collection[key].empty?
    end
  end

  def collection_params
    if can?(:manage, CourseCollection)
      params.require(controller_name.singularize).permit(:title, {description: []}, :members, :type)
    else
      params.require(controller_name.singularize).permit(:title, {description: []}).merge({members: params[controller_name.singularize][:members]})
    end
  end

  def class_uri(collection_type)
    case collection_type
    when 'course'
      CourseCollection.to_class_uri
    when 'personal'
      PersonalCollection.to_class_uri
    else
      raise ArgumentError.new("Unknown collection type")
    end
  end

  def curated_collection_path(collection)
    case collection.relationships(:has_model).first
    when CourseCollection.to_class_uri
      course_collection_path(collection)
    when PersonalCollection.to_class_uri
      personal_collection_path(collection)
    else
      raise ArgumentError.new("Unknown has_model relationship")
    end
  end
end
