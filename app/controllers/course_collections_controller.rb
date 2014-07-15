class CourseCollectionsController < CuratedCollectionsController
  def update
    # TODO change to member_attributes
    if members = collection_params[:members]
      @curated_collection.member_attributes = members
    end
    @curated_collection.attributes = collection_params.except(:members, :type)
    if @curated_collection.save
      if @curated_collection.root?
        redirect_to root_path
      else
        redirect_to curated_collection_path(@curated_collection)
      end
    end
  end
end
