require 'rails_helper'

describe CourseCollectionSolrProxy do

  context "for a CourseCollection" do
    before { CourseCollection.destroy_all }

    let!(:collection) { FactoryGirl.create(:course_collection) }

    describe "root" do
      subject { CourseCollectionSolrProxy.root }

      it "should have member_ids" do
        expect(subject.member_ids).to eq [collection.id]
      end
    end
  end

  describe "model_name" do
    it "should be CourseCollection" do
      expect(CourseCollectionSolrProxy.model_name).to eq "CourseCollection"
    end
  end
end

