class CuratedCollectionsController < ApplicationController
  include Blacklight::Catalog::SearchContext
  load_and_authorize_resource instance_name: :curated_collection

  ##
  # If the current action should start a new search session, this should be
  # set to true
  def start_new_search_session?
    false
  end

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
    new_type = params[:collection_type]
    @curated_collection.clear_relationship(:has_model)
    @curated_collection.add_relationship(:has_model, class_uri(new_type))
    if @curated_collection.save
      update_collection_parent(new_type)
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
      format.html do
        @curated_collection.ancestors_and_self.each do |s|
          add_breadcrumb s, s
        end
        @members = @curated_collection.members.select { |m| m.displays.include?('tdil') && m.state == 'A' }
      end
      format.pptx do
        send_file(@curated_collection.to_pptx,
                  filename: @curated_collection.pptx_file_name,
                  type: "application/vnd.openxmlformats-officedocument.presentationml.presentation")
      end
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

  def update_collection_parent(collection_type)
    # remove the collection from it's former parent
    old_parent = @curated_collection.parent
    old_parent.delete_member_by_id(@curated_collection.id)
    old_parent.save

    # add it to the root of the new collection type
    case collection_type
      when 'personal' # the collection was just downgraded to a PersonalCollection
        new_parent = User.find_by_user_key(@curated_collection.creator).personal_collection(true)

      when 'course'   # the collection was just upgraded to a CourseCollection
        new_parent = CourseCollection.root
    end

    new_parent.member_ids = [@curated_collection.id] + new_parent.member_ids
    new_parent.save

  end
end
