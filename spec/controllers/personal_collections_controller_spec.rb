require 'rails_helper'

describe PersonalCollectionsController do
  let(:image) { FactoryGirl.create(:image) }
  let(:collection) { FactoryGirl.create(:personal_collection, user: user) }
  let(:not_my_collection) { FactoryGirl.create(:personal_collection) }

  describe "for an unauthenticated user" do
    describe "create" do
      it "redirects to sign in" do
        post 'create', personal_collection: {title: 'foo'}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET 'show'" do
      it "redirects to sign in" do
        get :show, id: 'collection:1'
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "PATCH 'append_to'" do
      it "redirects to sign in" do
        patch 'append_to', id: 'collection:1', pid: 'pid:1'
        expect(response).to redirect_to new_user_session_path
      end
    end
  end


  describe "for a non-admin user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    describe "GET 'show'" do
      it "returns http success" do
        get :show, id: collection
        expect(response).to render_template(:show)
        expect(assigns[:curated_collection]).to eq collection
        expect(response).to be_successful
      end
    end

    describe "GET 'edit'" do
      it "returns http success" do
        get :edit, id: collection
        expect(response).to render_template(:edit)
        expect(assigns[:curated_collection]).to eq collection
        expect(response).to be_successful
      end
    end

    describe "GET 'new'" do
      it "returns http success" do
        get :new
        expect(response).to render_template(:new)
        expect(assigns[:curated_collection]).to be_kind_of PersonalCollection
        expect(response).to be_successful
      end
    end

    describe "POST 'create'" do
      it 'creates a personal collection' do
        expect {
          post 'create', personal_collection: {title: 'foo'}
        }.to change {PersonalCollection.count }.by(1)

        expect(response.status).to eq 302
        expect(assigns[:curated_collection].read_groups).to eq ['public']
        expect(assigns[:curated_collection].edit_users).to eq [user.user_key]
        expect(assigns[:curated_collection].displays).to eq ['tdil']
      end

      context 'with a bad title' do
        it "displays the form to fix the title" do
          count = PersonalCollection.count
          post 'create', personal_collection: {title: nil}
          expect(PersonalCollection.count).to eq count
          expect(response).to be_successful
          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH append_to" do
      context 'my own collection' do
        it "returns http success" do
          patch 'append_to', id: collection, pid: image.pid
          expect(response).to be_successful
          expect(collection.reload.members).to eq [image]
        end
      end

      context 'someone elses collection' do
        it "denies access" do
          expect{
            patch 'append_to', id: not_my_collection, pid: image.pid
          }.to raise_error(CanCan::AccessDenied)
        end
      end
    end

    describe "PATCH update" do
      context 'my own collection with images' do
        let(:image1) { FactoryGirl.create(:image) }
        let(:image2) { FactoryGirl.create(:image) }
        let(:image3) { FactoryGirl.create(:image) }

        before do
          collection.member_ids = [image1.id, image1.id, image1.id, image2.id, image3.id]
          collection.save!
        end

        it "reorders the collection" do
          patch :update, id: collection, personal_collection: {members: {"0"=>{"id"=>image1.id, "weight"=>"1"}, "1"=>{"id"=>image1.id, "weight"=>"2"}, "2"=>{"id"=>image1.id, "weight"=>"3"}, "3"=>{"id"=>image2.id, "weight"=>"4"}, "4"=>{"id"=>image3.id, "weight"=>"0"}}}
          expect(response).to redirect_to collection
          expect(collection.reload.member_ids).to eq [image3.id, image1.id, image1.id, image1.id, image2.id]

        end
      end

      context 'someone elses collection' do
        it "denies access" do
          expect{
            patch :update, id: not_my_collection, personal_collection: {}
          }.to raise_error(CanCan::AccessDenied)
        end
      end
    end
  end


  describe "for an admin user" do
    let(:user) { FactoryGirl.create(:admin) }
    before { sign_in user }

    describe "GET 'show'" do
      it "returns http success" do
        get :show, id: collection
        expect(response).to render_template(:show)
        expect(assigns[:curated_collection]).to eq collection
        expect(response).to be_successful
      end
    end
  end

end
