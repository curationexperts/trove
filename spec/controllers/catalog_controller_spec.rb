require 'rails_helper'

describe CatalogController do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

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

  describe "authenticated user" do
    before { sign_in user }

    describe "GET index" do
      before do
        PersonalCollection.delete_all
        CourseCollection.delete_all
      end

      describe "with draft and published objects" do
        let!(:draft_record) {
          TuftsImage.build_draft_version(displays: ['trove'], title: "draft image").tap do |r|
            r.save!
          end
        }

        let!(:published_record) {
          TuftsImage.create!(displays: ['trove'], title: "published image", pid: "tufts:123")
        }

        let!(:published_uc_record) {
          TuftsImage.create!(displays: ['trove'], title: "published image", pid: "tufts.uc:123")
        }

        it 'displays only the published records' do
          get :index
          records = assigns[:document_list].map(&:id)

          expect(records).to include(published_record.pid)
          expect(records).to include(published_uc_record.pid)
        end
      end

      describe "the sidebar" do
        let!(:my_collection1) { create(:personal_collection, user: user) }
        let!(:my_collection2) { create(:personal_collection, user: user) }
        let!(:not_my_collection) { create(:personal_collection) }

        it "should be a great success" do
          get :index
          expect(response).to be_success
          expect(assigns[:my_collection]).to eq user.personal_collection_proxy
          expect(assigns[:root_collection]).to eq CourseCollectionSolrProxy.root
        end
      end

      describe "the search results" do
        let!(:course_collection) { create(:course_collection) }
        let!(:image) { TuftsImage.create!(displays: 'trove', title: 'published image', pid: "tufts:123") }
        let(:soft_deleted_image) { TuftsImage.create(displays: ['trove'], title: 'soft-deleted', pid: "tufts:456") }
        let!(:template) { create(:tufts_template, displays: ['trove']) }
        let!(:pdf) { create(:tufts_pdf, displays: ['trove']) }

        before do
          soft_deleted_image.state = 'D'
          soft_deleted_image.save!
        end

        it "only shows images and collections" do
          get :index
          found = assigns[:document_list].map(&:id)
          expect(found).to include(course_collection.pid, image.pid)
          expect(found).to_not include(template.pid)
          expect(found).to_not include(pdf.pid)
          expect(found).to_not include(CourseCollection::ROOT_PID)
          expect(found).to_not include(soft_deleted_image.pid)
        end
      end

      describe "preferred view" do
        it "should save" do
          get :index, q: 'foo', view: 'gallery'
          expect(session[:preferred_view]).to eq 'gallery'
        end

        context "when they have a preferred view" do
          before do
            session[:preferred_view] = 'gallery'
          end

          it "should use the saved preference" do
            get :index, q: 'foo'
            expect(controller.params[:view]).to eq 'gallery'
          end
        end

      end
    end

    describe "GET show" do
      let(:published_trove_image) do
        TuftsImage.create!(displays: ['trove'], title: 'published trove image', pid: "tufts:123")
      end

      let(:published_dl_image) do
        TuftsImage.create!(displays: ['dl'], title: 'published dl image', pid: "tufts:4321")
      end

      context 'published images with "trove" display' do
        it 'is successful' do
          get :show, id: published_trove_image.pid

          expect(response).to be_successful
          expect(response).to render_template(:show)
          expect(assigns[:document]).to_not be_nil
        end
      end

      context 'published images with non-trove display' do
        it 'denies access' do
          get :show, id: published_dl_image.pid

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/You do not have sufficient access/)
        end
      end

      context 'for draft objects' do

        let(:draft_image) do
          TuftsImage.build_draft_version(displays: ['trove'], title: 'draft image').tap do |img|
            img.save!
          end
        end

        it 'denies access to draft objects' do
          get :show, id: draft_image
          expect(response.status).to eq(404)
        end

      end
    end

    describe "PATCH add_to_collection" do
      let(:image) { create(:tufts_image, displays: ['trove']) }
      it "adds to my collection" do
        collection = create(:personal_collection, user: user, displays: ['trove'])
        patch :add_to_collection, id: image.id, collection_id: collection.id
        expect(response).to redirect_to(catalog_path(image))
        expect(collection.reload.members).to include(image)
      end

      it "doesn't add to another user's collection" do
        collection = create(:personal_collection, displays: ['trove'])
        patch :add_to_collection, id: image.id, collection_id: collection.id
        expect(collection.reload.members).to_not include(image)
      end

      it "doesn't add to a course collection" do
        collection = create(:course_collection, displays: ['trove'])
        patch :add_to_collection, id: image.id, collection_id: collection.id
        expect(collection.reload.members).to_not include(image)
      end

      it "shows an error for non-existent collection" do
        patch :add_to_collection, id: image.id, collection_id: nil
        expect(response).to render_template(:show)
        expect(flash.now[:error]).to match /unable to add this to the collection/
      end
    end
  end

  describe "authenticated user" do
    let(:image) { create(:tufts_image, displays: ['trove']) }
    before { sign_in admin }

    describe "PATCH add_to_collection" do
      it "adds to my collection" do
        collection = create(:personal_collection, user: admin, displays: ['trove'])
        patch :add_to_collection, id: image.id, collection_id: collection.id
        expect(response).to redirect_to(catalog_path(image))
        expect(collection.reload.members).to include(image)
      end

      it "adds to another user's collection" do
        collection = create(:personal_collection, displays: ['trove'])
        patch :add_to_collection, id: image.id, collection_id: collection.id
        expect(response).to redirect_to(catalog_path(image))
        expect(collection.reload.members).to include(image)
      end

      it "adds to a course collection" do
        collection = create(:course_collection, displays: ['trove'])
        patch :add_to_collection, id: image.id, collection_id: collection.id
        expect(response).to redirect_to(catalog_path(image))
        expect(collection.reload.members).to include(image)
      end
    end
  end
end
