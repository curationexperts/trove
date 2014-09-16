require 'rails_helper'

describe PersonalCollectionsController do
  before { PersonalCollection.destroy_all }

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

      it "as .pptx redirects to sign in" do
        get :show, id: 'collection:1', format: 'pptx'
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
        expect(controller).to receive(:add_breadcrumb).with(collection, collection)
        get :show, id: collection
        expect(response).to render_template(:show)
        expect(assigns[:curated_collection]).to eq collection
        expect(response).to be_successful
      end

      context "when the collection is a course collection" do
        let(:collection) { create(:course_collection) }
        it "redirects to the course collection controller" do
          get :show, id: collection
          expect(response).to redirect_to collection
        end
      end
    end

    describe "GET 'show' with a PPTX" do
      let(:file) { Tempfile.new('mock_download') }

      before do
        file.write 'mock pptx'
        file.rewind
      end

      it "returns http success" do
        expect_any_instance_of(PersonalCollection).to receive(:to_pptx).and_return(file)
        expect_any_instance_of(PersonalCollection).to receive(:pptx_file_name).and_return('title_9.pptx')
        get :show, id: collection, format: 'pptx'
        expect(response).to be_successful
        expect(response.body).to eq 'mock pptx'
        expect(response.content_type).to eq 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
        expect(response.headers["Content-Disposition"]).to eq "attachment; filename=\"title_9.pptx\""
      end
    end

    describe "GET 'show' with a PDF" do
      let(:file) { Tempfile.new('mock_download') }

      before do
        file.write 'mock pdf'
        file.rewind
      end

      it "returns http success" do
        expect_any_instance_of(PersonalCollection).to receive(:to_pdf).and_return(file)
        expect_any_instance_of(PersonalCollection).to receive(:pdf_file_name).and_return('title_9.pdf')
        get :show, id: collection, format: 'pdf'
        expect(response).to be_successful
        expect(response.body).to eq 'mock pdf'
        expect(response.content_type).to eq 'application/pdf'
        expect(response.headers["Content-Disposition"]).to eq "attachment; filename=\"title_9.pdf\""
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

    describe "GET 'index'" do
      it "returns an error" do
        expect{
          get :index
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe "POST 'create'" do
      before do
        user.personal_collection
      end
      it 'creates a personal collection' do
        expect {
          post 'create', personal_collection: {title: 'foo'}
        }.to change { PersonalCollection.count }.by(2) #once for the root collection, once for the new collection.

        expect(response.status).to eq 302
        expect(assigns[:curated_collection].read_groups).to eq ['public']
        expect(assigns[:curated_collection].edit_users).to eq [user.user_key]
        expect(assigns[:curated_collection].displays).to eq ['tdil']
      end

      context 'with a bad title' do
        it "displays the form to fix the title" do
          expect {
            post 'create', personal_collection: {title: nil}
          }.not_to change { PersonalCollection.count }
          expect(response).to be_successful
          expect(response).to render_template(:new)
        end
      end
    end

    describe "DELETE destroy" do
      context 'my own collection' do
        let!(:collection) { FactoryGirl.create(:personal_collection, user: user) }
        it "deletes the collection" do
          expect{
            delete :destroy, id: collection
            expect(response).to redirect_to root_path
          }.to change { PersonalCollection.count }.by(-1)
        end
      end

      context 'someone elses collection' do
        it "denies access" do
          expect{
            delete :destroy, id: not_my_collection
          }.to raise_error(CanCan::AccessDenied)
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

    describe "DELETE remove_from" do
      context 'my own collection' do
        before do
          collection.members = [image]
          collection.save!
        end
        it "returns http success" do
          delete 'remove_from', id: collection, position: '0'
          expect(response).to redirect_to collection
          expect(collection.reload.members).to eq []
        end
      end

      context 'someone elses collection' do
        it "denies access" do
          expect{
            delete 'remove_from', id: not_my_collection, position: '1'
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
          patch :update, id: collection, personal_collection: {member_attributes: {"0"=>{"id"=>image1.id, "weight"=>"1"}, "1"=>{"id"=>image1.id, "weight"=>"2"}, "2"=>{"id"=>image1.id, "weight"=>"3"}, "3"=>{"id"=>image2.id, "weight"=>"4"}, "4"=>{"id"=>image3.id, "weight"=>"0"}}}
          expect(response).to redirect_to collection
          expect(collection.reload.member_ids).to eq [image3.id, image1.id, image1.id, image1.id, image2.id]
        end

        it "updates collection attributes" do
          patch :update, id: collection, personal_collection: {title: 'new title', description: ['new description']}
          collection.reload
          expect(collection.title).to eq 'new title'
          expect(collection.description).to eq ['new description']
        end

        it "doesn't update the collection type" do
          patch :update, id: collection, personal_collection: {type: 'course'}
          # reload manually to see if the class changed
          reloaded = ActiveFedora::Base.find(collection.pid, cast: true)
          expect(reloaded.type).to eq 'personal'
          expect(response).to redirect_to(personal_collection_path(reloaded))
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

    describe "GET 'index'" do
      it "returns http success" do
        get :index
        expect(response).to render_template(:index)
        expect(assigns[:solr_response]).to be_kind_of Blacklight::SolrResponse
        expect(response).to be_successful
      end
    end

    describe "PATCH update" do
      context 'my own collection' do

        let(:collection_w_creator) { FactoryGirl.create(:personal_collection, user: user) }

        it "updates the collection type" do
          patch :update_type, id: collection_w_creator
          # reload manually to see if the class changed
          reloaded = ActiveFedora::Base.find(collection_w_creator.pid)
          expect(reloaded.type).to eq 'course'
          expect(response).to redirect_to(course_collection_path(reloaded))
        end

        it "updates the collection parent" do
          patch :update_type, id: collection_w_creator
          expect(user.personal_collection.member_ids).not_to include(collection_w_creator.id)
          expect(CourseCollection.root.member_ids).to include(collection_w_creator.id)
        end

      end
    end
  end

end
