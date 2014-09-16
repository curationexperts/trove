class CourseCollectionsController < CuratedCollectionsController
  rescue_from Tufts::ModelNotAsserted do
    redirect_to personal_collection_path(params[:id])
  end
end
