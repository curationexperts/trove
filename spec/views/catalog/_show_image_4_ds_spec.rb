require 'rails_helper'

describe 'catalog/_show_image_4_ds.html.erb' do

  let(:image) { FactoryGirl.create(:image) }
  let(:collection) { FactoryGirl.create(:course_collection) }

  before do
    allow(view).to receive(:blacklight_config) { CatalogController.new.blacklight_config }
    collection.members = [image]
    collection.save!
    render partial: 'catalog/show_image_4_ds',
           locals: { document: SolrDocument.new(image.to_solr) }
  end

  it 'displays links to the collections it belongs to' do
    expect(rendered).to have_link(collection.title, href: course_collection_path(collection))
  end

end
