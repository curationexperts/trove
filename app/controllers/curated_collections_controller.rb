class CuratedCollectionsController < ApplicationController
  include Blacklight::Catalog::SearchContext
  load_and_authorize_resource instance_name: :curated_collection

  def create
    @curated_collection.active_user = current_user if @curated_collection.is_a? PersonalCollection
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
    # TODO consolidate
    if members = collection_params[:member_attributes]
      @curated_collection.member_attributes = members
    elsif collections = collection_params[:collection_attributes]
      @curated_collection.collection_attributes = collections
    end
    @curated_collection.attributes = collection_params.except(:member_attributes, :collection_attributes, :type)
    if @curated_collection.save
      if @curated_collection.root?
        redirect_to root_path
      else
        redirect_to curated_collection_path(@curated_collection)
      end
    end
  end

  def update_type
    params.require(:collection_type)
    # can't figure out how to require specific values using strong_parameters
    if not ['personal', 'course'].include?(params[:collection_type])
      raise ActiveModel::ForbiddenAttributes.new
    end
    @curated_collection.clear_relationship(:has_model)
    @curated_collection.add_relationship(:has_model, class_uri(params[:collection_type]))
    if @curated_collection.save
      redirect_to curated_collection_path(@curated_collection)
    else
      render :show
    end
  end

  def edit
    initialize_fields
  end

  def show
    respond_to do |format|
      format.html
      format.pptx {
        send_file(@curated_collection.to_pptx,
                  filename: @curated_collection.pptx_file_name,
                  type: "application/vnd.openxmlformats-officedocument.presentationml.presentation")
      }
    end
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
    if record.kind_of?(CuratedCollection) && record.parent_count > 0
      render json: { status: 'error', message: 'The collection already has a parent' }, status: :forbidden
    else
      @curated_collection.members << record
      status = @curated_collection.save ? 'success' : 'error'
      render json: { status: status }
    end
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
    params.require(controller_name.singularize).permit(:title, {description: []}, :members, :member_ids)
    params[controller_name.singularize]
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
