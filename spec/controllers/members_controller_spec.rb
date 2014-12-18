require 'rails_helper'

describe MembersController do
  let(:image) { create(:image, displays: ['trove']) }
  let(:collection) { create(:course_collection) }

  describe "for an unauthenticated user" do
    describe "GET 'show'" do
      it "redirects to sign in" do
        get :show, course_collection_id: collection, id: 1
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "for a non-admin user" do
    let(:user) { create(:user) }
    before { sign_in user }

    describe "GET 'show'" do
      let(:image1) { create(:tufts_image, displays: ['trove']) }
      let(:image2) { create(:tufts_image, displays: ['trove']) }
      let(:image3) { create(:tufts_image, displays: ['trove']) }
      let(:displays_dl) { create(:tufts_image, displays: ['dl']) }
      let(:deleted_record) { create(:tufts_image, displays: ['trove']) }
      let(:soft_deleted_record) { create(:tufts_image, displays: ['trove']) }

      context "with some members" do
        before do
          # Fedora won't let you create a deleted record, so create & then update as deleted:
          soft_deleted_record.state = 'D'
          soft_deleted_record.save!
          collection.members = [image1, image2, displays_dl, deleted_record, soft_deleted_record, image3]
          collection.save!
          deleted_record.delete
        end

        it "returns http success" do
          get :show, course_collection_id: collection, id: 2
          expect(response).to be_successful
          expect(assigns[:collection]).to eq collection
          expect(assigns[:document]['id']).to eq image2.pid
          expect(assigns[:prev_position]).to eq 1
          expect(assigns[:next_position]).to eq 5
          expect(response).to render_template(:show)
        end

        it "doesn't show prev link for the first item" do
          get :show, course_collection_id: collection, id: 1
          expect(assigns[:document]['id']).to eq image1.pid
          expect(assigns[:prev_position]).to eq nil
          expect(assigns[:next_position]).to eq 2
        end

        it "doesn't show next link for the last item" do
          get :show, course_collection_id: collection, id: 5
          expect(assigns[:document]['id']).to eq image3.pid
          expect(assigns[:prev_position]).to eq 2
          expect(assigns[:next_position]).to eq nil
        end

        it "redirects when viewing members that don't display in trove" do
          get :show, course_collection_id: collection, id: 3
          expect(response).to redirect_to course_collection_path(collection)
        end

        it "redirects when viewing soft-deleted members" do
          get :show, course_collection_id: collection, id: 4
          expect(response).to redirect_to course_collection_path(collection)
        end

        context "when the collection is a personal collection" do
          let(:collection) { create(:personal_collection) }
          it "returns http success" do
            get :show, personal_collection_id: collection, id: 2
            expect(response).to be_successful
            expect(assigns[:collection]).to eq collection
            expect(assigns[:document]['id']).to eq image2.pid
          end
        end
      end

      context "when the prev and next members are soft deleted" do
        before do
          # Fedora won't let you create a deleted record, so create & then update as deleted:
          image1.state = 'D'
          image1.save!
          image3.state = 'D'
          image3.save!
          collection.members = [image1, image2, image3]
          collection.save!
        end

        it "doesn't show next or prev link" do
          get :show, course_collection_id: collection, id: 2
          expect(assigns[:document]['id']).to eq image2.pid
          expect(assigns[:prev_position]).to eq nil
          expect(assigns[:next_position]).to eq nil
        end
      end
    end
  end

  describe "an admin user" do
    let(:user) { create(:admin) }
    let(:collection) { create(:course_collection, members: [image]) }
    before { sign_in user }

    describe "GET 'show'" do
      it "returns http success" do
        get :show, course_collection_id: collection, id: 1
        expect(response).to be_successful
        expect(assigns[:collection]).to eq collection
        expect(assigns[:document]['id']).to eq image.pid
        expect(response).to render_template(:show)
      end
    end
  end
end

