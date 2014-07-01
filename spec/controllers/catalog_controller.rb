require 'rails_helper'

describe CatalogController do
  let(:user) { FactoryGirl.create(:user) }
  describe "GET index" do
    before do
      PersonalCollection.destroy_all
      CourseCollection.destroy_all
      sign_in user
    end
    let!(:my_collection1) { FactoryGirl.create(:personal_collection) }
    let!(:my_collection2) { FactoryGirl.create(:personal_collection) }
    let!(:course_collection1) { FactoryGirl.create(:course_collection) }
    let!(:course_collection2) { FactoryGirl.create(:course_collection) }

    it "should be a great success" do
      get :index
      expect(response).to be_success
      expect(assigns[:my_collections]).to eq [my_collection1, my_collection2]
      expect(assigns[:course_collections]).to eq [course_collection1, course_collection2]
    end
  end
end
