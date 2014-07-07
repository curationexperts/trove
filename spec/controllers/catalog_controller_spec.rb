require 'rails_helper'

describe CatalogController do
  let(:user) { FactoryGirl.create(:user) }

  describe "GET index" do
    before do
      PersonalCollection.destroy_all
      CourseCollection.destroy_all
      sign_in user
    end
    let!(:my_collection1) { FactoryGirl.create(:personal_collection, user: user) }
    let!(:my_collection2) { FactoryGirl.create(:personal_collection, user: user) }
    let!(:not_my_collection) { FactoryGirl.create(:personal_collection) }
    let!(:course_collection1) { FactoryGirl.create(:course_collection) }
    let!(:course_collection2) { FactoryGirl.create(:course_collection) }

    it "should be a great success" do
      get :index
      expect(response).to be_success
      expect(assigns[:my_collections]).to eq [my_collection1, my_collection2]
      expect(assigns[:course_collections]).to eq [course_collection1, course_collection2]
    end
  end

  describe "GET show" do
    before { sign_in user }

    context 'images with "tdil" display' do
      let(:tdil_img) { FactoryGirl.create(:image, displays: ['tdil']) }

      it 'is successful' do
        get :show, id: tdil_img.pid
        expect(response).to render_template(:show)
        expect(response).to be_successful
        expect(assigns[:document]).to_not be_nil
      end
    end

    context 'images with non-tdil display' do
      let(:dl_img) { FactoryGirl.create(:image, displays: ['dl']) }
      it 'denies access' do
        get :show, id: dl_img.pid
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to match(/You do not have sufficient access/)
      end
    end
  end

  describe "an unauthenticated user" do
    describe "GET index" do
      it "redirects to sign in" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET show" do
      it "redirects to sign in" do
        get :show, id: 1
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

end
