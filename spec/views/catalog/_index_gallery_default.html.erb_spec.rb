require 'rails_helper'

describe 'catalog/_index_gallery_default' do
  let(:description) {
    'A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy'
  }

  let(:document) { SolrDocument.new('description_tesim' => [description]) }

  before do
    allow(view).to receive(:document).and_return(document)
  end

  it "should truncate the description" do
    render
    expect(rendered).to have_text 'A wonderful serenity has taken possession of my entire soul, like these sweet mornings...'
  end
end
