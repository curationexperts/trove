require 'rails_helper'

describe CollectionSolrProxy do

  describe "id" do
    subject { CollectionSolrProxy.new(id: 'tufts.uc:77', title: 'Test title') }

    it "should have id" do
      expect(subject.id).to eq 'tufts.uc:77'
    end

    it "should have title" do
      expect(subject.title).to eq 'Test title'
    end
  end

  describe "exists?" do
    context "when it doesn't exist" do
      subject { CollectionSolrProxy.new(id: 'foo:bar', title: 'Test title') }
      it "should be false" do
        expect(subject.exists?).to be false
      end
    end
    context "when it exists" do
      subject { CollectionSolrProxy.new(id: FactoryGirl.create(:personal_collection).id) }
      it "should be true" do
        expect(subject.exists?).to be true
      end
    end

  end


end
