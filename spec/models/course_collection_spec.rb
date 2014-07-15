require 'rails_helper'

describe CourseCollection do

  subject { CourseCollection.new title: 'some title' }

  describe "members" do
    context "when it's empty" do
      it "has an empty list of members" do
        expect(subject.members).to eq []
      end

      it "has an empty list of member_ids" do
        expect(subject.member_ids).to eq []
      end
    end

    context "when it's not empty" do
      let(:img1) { FactoryGirl.create('tufts_image') }
      let(:img2) { FactoryGirl.create('tufts_image') }
      let(:img3) { FactoryGirl.create('tufts_image') }

      before do
        subject.members << img1
        subject.members << img2
      end

      it "lists the members" do
        expect(subject.members).to eq [img1, img2]
      end

      it "lists the members_ids" do
        expect(subject.member_ids).to eq [img1.id, img2.id]
      end

      it "adding members persists when saved" do
        subject.save!
        expect(subject.members).to eq [img1, img2]
        subject.member_ids << img3.pid
        subject.save!
        subject.reload
        expect(subject.members(true)).to eq [img1, img2, img3]
      end

      describe '#to_solr' do
        it 'lists the members' do
          solr_doc = subject.to_solr
          expect(solr_doc['member_ids_ssim']).to eq [img1.id, img2.id]
          expect(solr_doc['member_ids_ssim'].first.class).to eq String
        end
      end
    end
  end

  describe "setting nested member_attributes" do
    before do
      CourseCollection.destroy_all
    end
    let(:root) { CourseCollection.root }
    let(:collection1) { FactoryGirl.create(:course_collection) }
    let(:collection2) { FactoryGirl.create(:course_collection) }
    let(:collection3) { FactoryGirl.create(:course_collection) }

    it "sets the children" do
      root.member_attributes = {"0"=>{"id"=>collection3.id, "weight"=>"1", 'parent_page_id' => collection1.id}, "1"=>{"id"=>collection1.id, "weight"=>"3", 'parent_page_id' => root.id}, "2"=>{"id"=>collection2.id, "weight"=>"2", 'parent_page_id' => root.id}}
      expect(root.member_ids).to eq [collection2.id, collection1.id]
      expect(collection1.reload.member_ids).to eq [collection3.id]
    end

    it "sets the children to root when parent_page_id is blank" do
      root.member_attributes = {"0"=>{"id"=>collection3.id, "weight"=>"1", 'parent_page_id' => ''}, "1"=>{"id"=>collection1.id, "weight"=>"3", 'parent_page_id' => ''}, "2"=>{"id"=>collection2.id, "weight"=>"2", 'parent_page_id' => root.id}}
      expect(root.member_ids).to eq [collection3.id, collection2.id, collection1.id]
    end
  end

  describe "parents" do
    let(:child) { CourseCollection.create title: 'some title' }
    let(:parent1) { CourseCollection.create title: 'some title' }
    let(:parent2) { CourseCollection.create title: 'some title' }
    subject { child.parent_count }

    context "without an explicit parent (child of root)" do
      it { should eq 1 }
    end

    context "when it has many parents" do
      before do
        parent1.members << child
        parent1.save!
        parent2.members << child
        parent2.save!
      end

      it { should eq 3 }
    end
  end

  describe "to_class_uri" do
    it "sets the displays" do
      expect(subject.displays).to eq ['tdil']
    end

    it "allows tdil as a display" do
      expect(subject.save).to be true
    end
  end

  describe "groups" do
    it "should have read_groups" do
      subject.read_groups = ['public']
      expect(subject.read_groups).to eq ['public']
    end
  end

  describe "apply_depositor_metadata" do
    it "should set the depositor" do
      subject.apply_depositor_metadata('jcoyne')
      expect(subject.edit_users).to eq ['jcoyne']
    end
  end
end
