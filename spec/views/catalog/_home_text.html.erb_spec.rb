require 'rails_helper'

describe 'catalog/_home_text' do
  context "with featured images" do
    let(:image) { TuftsImage.new(pid: 'tufts:777') }
    before do
      expect(image).to receive(:new_record?).and_return(false)
      expect(view).to receive(:featured_records).and_return([image])
    end
    it "should draw a thumnail for the featured image" do
      render
      expect(rendered).to have_selector('img[src="/downloads/tufts:777?datastream_id=Basic.jpg"]')
    end
  end

  context "when one of the featured works is a collection" do
    let(:image) { TuftsImage.new(pid: 'tufts:888') }
    let(:collection) { CourseCollection.new() }
    before do
      expect(collection).to receive(:members).and_return([image])
      expect(view).to receive(:featured_records).and_return([collection])
    end
    it "should draw a thumnail for the first member of the collection" do
      render
      expect(rendered).to have_selector('img[src="/downloads/tufts:888?datastream_id=Basic.jpg"]')
    end
  end
end
