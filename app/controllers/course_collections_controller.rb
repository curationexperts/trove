class CourseCollectionsController < CuratedCollectionsController
  rescue_from Tufts::ModelNotAsserted do
    redirect_to personal_collection_path(params[:id])
  end

  protected

  def switch_type_actor
    SwitchToPersonalCollectionActor.new(@curated_collection)
  end

end
