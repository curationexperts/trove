class PersonalCollectionsController < CuratedCollectionsController
  def index
    authorize! :index, PersonalCollection
    @user_collections = User.all.map {|u| u.personal_collection_proxy }
  end
end
