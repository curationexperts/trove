class CuratedCollectionsController < ApplicationController
  include Blacklight::Catalog::SearchContext
  include CuratedCollectionHelper
  load_and_authorize_resource instance_name: :curated_collection

  ##
  # If the current action should start a new search session, this should be
  # set to true
  def start_new_search_session?
    false
  end

  def create
    build_collection(@curated_collection)
    @curated_collection.attributes = collection_params
    if @curated_collection.save
      redirect_to (params[:return_url] || root_path)
    else
      render :new
    end
  end

  def copy
    @cloned = duplicate(@curated_collection)
    redirect_to root_path

  end

  def update
    if collection_params[:member_attributes].present?
      # updating from the edit page
      members = collection_params[:member_attributes].reject do |orig_position, member|
        member["remove"] == "remove"
      end
      @curated_collection.member_attributes = members
    elsif collections = collection_params[:collection_attributes]
      # reordering from the search results page
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
    if switch_type_actor.switch
      redirect_to curated_collection_path(@curated_collection)
    else
      render :show
    end
  end


  def edit
    initialize_fields
    @members, @positions = members_with_positions(@curated_collection)
  end

  def show
    respond_to do |format|
      format.html do
        @curated_collection.ancestors_and_self.each do |s|
          add_breadcrumb s, s
        end
        @members, @positions = members_with_positions(@curated_collection)
        @position_of_first_flattened_member = position_of_first_visible_flattened_member(@curated_collection)
      end
      format.pptx do
        exporter = PowerPointCollectionExporter.new(@curated_collection)
        send_file(exporter.export,
                  filename: exporter.pptx_file_name,
                  type: "application/vnd.openxmlformats-officedocument.presentationml.presentation")
      end
      format.pdf do
        exporter = PdfCollectionExporter.new(@curated_collection)
        send_file(exporter.export, filename: exporter.pdf_file_name, type: "application/pdf")
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

  protected

  # this is the position we use for the first slide of the slideshow view
  def position_of_first_visible_flattened_member(curated_collection)
    _, position = curated_collection.flattened_member_ids.
      # add positions
      with_index.
      # get the first member visible to tdil
      find { |(pid,_)| visible_by_tdil?(pid) }
    position
  end

  def members_with_positions(curated_collection)
    members, positions = [curated_collection.members, curated_collection.positions_of_members].
      # transpose so we can drop non-tdil members with their positions
      transpose.
      # only show members visible to tdil
      select { |(member,_)| member.displays.include?('tdil') && member.state == 'A' }.
      # transpose back so we get something like this: [members, positions]
      transpose
    [(members || []), (positions || [])]
  end

  def duplicate(source, top_level=true)
    collection_class.new.tap do |dest|
      build_collection(dest, top_level)
      dest.title = source.title
      dest.description = source.description
      dest.members = source.members.map do |member|
        if member.is_a? CourseCollection
          duplicate(member, false).tap do |collection|
            collection.save!
          end
        else
          member
        end
      end
      dest.save!
    end
  end

  def collection_class
    if can? :create, CourseCollection
      @curated_collection.class
    elsif can? :create, PersonalCollection
      PersonalCollection
    end
  end

  def build_collection(collection, top_level=true)
    # if active_user is set, the collection gets added to that users top-level collection.
    collection.active_user = current_user if top_level && collection.is_a?(PersonalCollection)
    collection.read_groups = ['public']
    collection.displays = ['tdil']
    collection.apply_depositor_metadata(current_user)
    collection.creator = [current_user.user_key]
  end

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
end
