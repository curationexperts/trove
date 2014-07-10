require 'rails_helper'

describe 'catalog/_show_image_4_ds.html.erb' do

  let(:image) { FactoryGirl.create(:image) }
  let(:collection) { FactoryGirl.create(:course_collection) }
  let(:user) { FactoryGirl.create :user }

  before do
    allow(view).to receive(:blacklight_config) { CatalogController.new.blacklight_config }
    allow(view).to receive(:current_user) { user }
  end

  describe 'course collections' do
    before do
      collection.members = [image]
      collection.save!

      render partial: 'catalog/show_image_4_ds',
             locals: { document: SolrDocument.new(image.to_solr) }
    end

    it 'displays links to the collections it belongs to' do
      expect(rendered).to have_link(collection.title, href: course_collection_path(collection))
    end
  end

  describe 'personal collections' do
    let(:my_collection) { FactoryGirl.create(:personal_collection, user: user) }
    let(:other_collection) { FactoryGirl.create(:personal_collection) }

    before do
      my_collection.members = [image]
      my_collection.save!
      other_collection.members = [image]
      other_collection.save!

      render partial: 'catalog/show_image_4_ds',
             locals: { document: SolrDocument.new(image.to_solr) }
    end

    it 'displays links to my own personal collections' do
      expect(rendered).to_not have_link(other_collection.title, href: personal_collection_path(other_collection))
      expect(rendered).to have_link(my_collection.title, href: personal_collection_path(my_collection))
    end
  end

end
