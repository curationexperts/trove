require 'rails_helper'

describe CourseCollectionsController do
  let(:image) { create(:image) }
  let(:collection) { create(:course_collection) }

  describe "for an unauthenticated user" do
    describe "create" do
      it "redirects to sign in" do
        post 'create', course_collection: {title: 'foo'}
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
    let(:user) { create(:user) }
    before { sign_in user }

    describe "create" do
      it "denies access" do
        expect{
          post :create, course_collection: {title: 'foo'}
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe "DELETE 'destroy'" do
      it "denies access" do
        expect{
          delete :destroy, id: collection
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe "GET 'show'" do
      let(:displays_trove) { create(:tufts_image, displays: ['trove']) }
      let(:displays_dl) { create(:tufts_image, displays: ['dl']) }
      let(:deleted_record) { create(:tufts_image, displays: ['trove']) }
      let(:soft_deleted_record) { create(:tufts_image, displays: ['trove']) }

      before do
        # Fedora won't let you create a deleted record, so create & then update as deleted:
        soft_deleted_record.state = 'D'
        soft_deleted_record.save!
        # we put the visible member last so we can ensure the correct position is calculated
        collection.members = [displays_dl, deleted_record, soft_deleted_record, displays_trove]
        collection.save!
        deleted_record.delete
      end

      it "returns http success" do
        expect(controller).to receive(:add_breadcrumb).with(collection, collection)
        get :show, id: collection
        expect(response).to be_successful
        expect(assigns[:curated_collection]).to eq collection
        expect(assigns[:members]).to eq [displays_trove]

        # positions are taken from the model
        # see the note in MembersController#show for more info
        expect(assigns[:positions]).to eq [2]
        expect(assigns[:position_of_first_flattened_member]).to eq 2

        expect(response).to render_template(:show)
      end

      context "when the collection is a personal collection" do
        let(:collection) { create(:personal_collection) }
        it "redirects to the person collection controller" do
          get :show, id: collection
          expect(response).to redirect_to collection
        end
      end

      context "when the first member is another collection" do
        let(:sub_collection) { create(:course_collection, members: [displays_dl, displays_trove]) }
        before do
          collection.members = [sub_collection]
          collection.save!
        end
        it "links to the first member to start the slideshow" do
          get :show, id: collection
          expect(assigns[:position_of_first_flattened_member]).to eq 1
        end
      end
    end

    describe "PATCH 'append_to'" do
      it "denies access" do
        expect {
          patch :append_to, id: collection, pid: 'pid:1'
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe "POST 'copy'" do
      let(:nested_collection) { create(:course_collection) }
      let(:nested_image) { create(:tufts_image, displays: ['trove']) }

      before do
        PersonalCollection.delete_all
        nested_collection.members = [ nested_image ]
        nested_collection.save!
        collection.members = [ image, nested_collection ]
        collection.save!
      end

      it "creates a personal collection" do
        expect {
          post :copy, id: collection
        }.to change { PersonalCollection.count }.by(3)
        expect(response).to redirect_to root_path
        expect(assigns[:cloned].members.map(&:class)).to eq [TuftsImage, PersonalCollection]
        expect(assigns[:cloned].members[1].member_ids).to eq [nested_image.pid]
        expect(user.personal_collection.member_ids).to eq [assigns[:cloned].pid]
      end
    end
  end

  describe "an admin user" do
    let(:user) { create(:admin) }
    before { sign_in user }

    describe "POST 'create'" do
      it "creates a course collection" do
        expect {
          post :create, course_collection: { title: 'foo' }
        }.to change { CourseCollection.count }.by(1)

        expect(response.status).to eq 302
        expect(assigns[:curated_collection].read_groups).to eq ['public']
        expect(assigns[:curated_collection].edit_users).to eq [user.user_key]
        expect(assigns[:curated_collection].displays).to eq ['trove']
        expect(CourseCollection.root.member_ids.first).to eq assigns[:curated_collection].id
      end

      context 'with a bad title' do
        it "displays the form to fix the title" do
          count = CourseCollection.count
          post 'create', course_collection: {title: nil}
          expect(CourseCollection.count).to eq count
          expect(response).to be_successful
          expect(response).to render_template(:new)
        end
      end
    end

    describe "GET 'show'" do
      it "returns http success" do
        get :show, id: collection
        expect(response).to be_successful
        expect(assigns[:curated_collection]).to eq collection
        expect(response).to render_template(:show)
      end
    end

    describe "GET 'new'" do
      it "returns http success" do
        get :new
        expect(response).to render_template(:new)
        expect(assigns[:curated_collection]).to be_kind_of CourseCollection
        expect(response).to be_successful
      end
    end

    describe "GET 'edit'" do
      let(:image1) { create(:image, displays: ['dl']) }
      let(:image2) { create(:image, displays: ['trove']) }
      let(:collection) { create(:course_collection, members: [image1, image2]) }

      it "returns http success" do
        get :edit, id: collection
        expect(response).to render_template(:edit)
        expect(assigns[:curated_collection]).to eq collection
        expect(assigns[:members]).to eq [image2]

        # positions are taken from the model
        # see the note in MembersController#show for more info
        expect(assigns[:positions]).to eq [1]

        expect(response).to be_successful
      end

      context "with an empty collection" do
        let(:collection) { create(:course_collection) }
        it "creates arrays for @members and @positions" do
          get :edit, id: collection
          expect(assigns[:members]).to eq []
          expect(assigns[:positions]).to eq []
        end
      end

    end

    describe "DELETE 'destroy'" do
      let!(:collection) { create(:course_collection) }
      it "deletes the collection" do
        expect{
          delete :destroy, id: collection
          expect(response).to redirect_to root_path
        }.to change { CourseCollection.count }.by(-1)
      end
    end

    describe "PATCH 'append_to'" do
      it "returns http success" do
        patch :append_to, id: collection, pid: image.pid
        expect(response).to be_successful
        expect(collection.reload.members).to eq [image]
      end

      context "when it has a parent" do
        let(:child) { CourseCollection.create title: 'some title' }
        let(:parent) { CourseCollection.create title: 'some title' }

        before do
          parent.members << child
          parent.save!
        end

        it "doesn't allow a second parent" do
          patch :append_to, id: collection, pid: child.pid
          expect(response).to be_forbidden
          expect(collection.reload.members).to eq []
        end
      end
    end

    describe "PATCH update" do
      it "updates collection attributes" do
        patch :update, id: collection, course_collection: {title: 'new title', description: ['new description']}
        collection.reload
        expect(collection.title).to eq 'new title'
        expect(collection.description).to eq ['new description']
      end

      context 'course collection with images' do
        let(:image1) { create(:image) }
        let(:image2) { create(:image) }
        let(:image3) { create(:image) }

        it "reorders the collection" do
          patch :update, id: collection, course_collection: {member_attributes: {"0"=>{"id"=>image1.id, "weight"=>"1"}, "1"=>{"id"=>image1.id, "weight"=>"2"}, "2"=>{"id"=>image1.id, "weight"=>"3"}, "3"=>{"id"=>image2.id, "weight"=>"4"}, "4"=>{"id"=>image3.id, "weight"=>"0"}}}
          expect(response).to redirect_to collection
          expect(collection.reload.member_ids).to eq [image3.id, image1.id, image1.id, image1.id, image2.id]
        end

        context "when the collection has members" do
          let(:collection) { create(:course_collection, members: [image1, image2]) }

          it "removes members of the collection" do
            patch :update, id: collection, course_collection: {member_attributes: {"0"=>{"id"=>image1.id, "weight"=>"1", "remove"=>"remove"}, "1"=>{"id"=>image2.id, "weight"=>"2"}}}
            expect(response).to redirect_to collection
            expect(collection.reload.member_ids).to eq [image2.id]
          end
        end
      end

      context "with nested collections" do
        before { CourseCollection.delete_all }

        let(:root) { CourseCollection.root }
        let(:collection1) { create(:course_collection) }
        let(:collection2) { create(:course_collection) }
        let(:collection3) { create(:course_collection) }

        it "sets the children" do
          post :update, id: root, course_collection: {collection_attributes: {"0"=>{"id"=>collection3.id, "weight"=>"1", 'parent_page_id' => collection1.id}, "1"=>{"id"=>collection1.id, "weight"=>"3", 'parent_page_id' => root.id}, "2"=>{"id"=>collection2.id, "weight"=>"2", 'parent_page_id' => root.id}}}
          expect(root.reload.member_ids).to eq [collection2.id, collection1.id]
          expect(collection1.reload.member_ids).to eq [collection3.id]
          expect(response).to redirect_to root_path
        end
      end
    end

    describe "PATCH update_type" do

      let(:collection_w_creator) { create(:course_collection, creator: [user.user_key]) }

      it "updates the collection type" do
        patch :update_type, id: collection_w_creator
        # reload manually to see if the class changed
        reloaded = ActiveFedora::Base.find(collection_w_creator.pid)
        expect(reloaded.type).to eq 'personal'
        expect(response).to redirect_to(personal_collection_path(reloaded))
      end

      it "updates the collection parent" do
        patch :update_type, id: collection_w_creator
        expect(CourseCollection.root.member_ids).not_to include(collection_w_creator.id)
        expect(user.personal_collection.member_ids).to include(collection_w_creator.id)
      end

      describe "when the collection has child collections" do
        let(:parent) { build(:course_collection, creator: [user.user_key]) }
        let(:child) { create(:course_collection, creator: [user.user_key]) }

        before do
          parent.members << child
          parent.save!
        end

        it "updates the type of the children that are collections" do
          patch :update_type, id: parent
          reloaded_child = ActiveFedora::Base.find(child.pid)
          expect(reloaded_child).to be_instance_of PersonalCollection
        end
      end

    end
  end  # describe admin user

end

