class CourseCollectionsController < CuratedCollectionsController

protected

  def build_collection
    attributes = params.require(:curated_collection).permit(:title)
    @curated_collection = CourseCollection.new(attributes.symbolize_keys)
    @curated_collection.read_groups = ['public']
    @curated_collection.apply_depositor_metadata(current_user)
    @curated_collection.displays = ['tdil']
  end

  def load_collection
    @curated_collection = CourseCollection.find(params[:id])
  end

end
