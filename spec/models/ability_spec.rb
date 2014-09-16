require 'rails_helper'
require "cancan/matchers"

describe Ability do
  before :all do
    PersonalCollection.delete_all
    User.delete_all
  end
  let(:course_collection) { FactoryGirl.create(:course_collection) }
  let(:personal_collection) { FactoryGirl.create(:personal_collection) }
  let(:datastream) { ActiveFedora::Datastream.new }
  let(:image) do
    TuftsImage.new(title: 'test image', displays: ['dl']).tap do |image|
      image.read_groups = ['public']
      image.save!
    end
  end


  describe "an admin user" do
    let(:admin) { FactoryGirl.create(:admin) }
    subject { Ability.new(admin) }

    it { should be_able_to(:download, datastream) }
    it { should be_able_to(:create, CourseCollection) }
    it { should be_able_to(:append_to, course_collection) }
    it { should be_able_to(:remove_from, course_collection) }
    it { should_not be_able_to(:destroy, CourseCollection.root) }
    it { should be_able_to(:destroy, course_collection) }
    it { should be_able_to(:edit, course_collection) }
    it { should be_able_to(:show, course_collection) }
    it { should be_able_to(:create, PersonalCollection) }
    it { should be_able_to(:show, personal_collection) }
    it { should be_able_to(:index, PersonalCollection) }

    context 'my own PersonalCollection' do
      let(:collection) { FactoryGirl.create(:personal_collection, user: admin) }
      it { should be_able_to(:append_to, collection) }
      it { should be_able_to(:remove_from, collection) }
      it { should be_able_to(:destroy, collection) }
    end

    context 'someone elses PersonalCollection' do
      it { should be_able_to(:append_to, personal_collection) }
      it { should be_able_to(:remove_from, personal_collection) }
      it { should be_able_to(:destroy, personal_collection) }
    end

    context 'a personal collection proxy' do
      let(:collection_proxy) { PersonalCollectionSolrProxy.new(id: 'foo:bar') }
      it { should be_able_to(:append_to, collection_proxy) }
      it { should be_able_to(:remove_from, collection_proxy) }
    end

    context 'a course collection proxy' do
      let(:collection_proxy) { CourseCollectionSolrProxy.new(id: 'foo:bar') }
      it { should be_able_to(:append_to, collection_proxy) }
      it { should be_able_to(:remove_from, collection_proxy) }
    end
  end


  describe "a non-admin user" do
    let(:user) { FactoryGirl.create(:user) }
    subject { Ability.new(user) }

    it { should be_able_to(:download, datastream) }
    it { should_not be_able_to(:create, CourseCollection) }
    it { should_not be_able_to(:append_to, course_collection) }
    it { should_not be_able_to(:remove_from, course_collection) }
    it { should_not be_able_to(:destroy, course_collection) }
    it { should_not be_able_to(:edit, course_collection) }
    it { should     be_able_to(:show, course_collection) }

    it { should     be_able_to(:create, PersonalCollection) }
    it { should_not be_able_to(:index, PersonalCollection) }

    context 'my own PersonalCollection' do
      let(:collection) { FactoryGirl.create(:personal_collection, user: user) }
      it { should be_able_to(:append_to, collection) }
      it { should be_able_to(:remove_from, collection) }
      it { should be_able_to(:read, collection) }
      it { should be_able_to(:update, collection) }
      it { should be_able_to(:update, user.personal_collection(true)) }
      it { should be_able_to(:destroy, collection) }

      context 'proxy' do
        let(:collection_proxy) { PersonalCollectionSolrProxy.new(id: collection.id) }
        it { should be_able_to(:append_to, collection_proxy) }
        it { should be_able_to(:remove_from, collection_proxy) }
      end
    end

    context 'someone elses PersonalCollection' do
      it { should_not be_able_to(:append_to, personal_collection) }
      it { should_not be_able_to(:remove_from, personal_collection) }
      it { should_not be_able_to(:show, personal_collection) }
      context 'proxy' do
        let(:collection_proxy) { PersonalCollectionSolrProxy.new(id: personal_collection.id) }
        it { should_not be_able_to(:append_to, collection_proxy) }
        it { should_not be_able_to(:remove_from, collection_proxy) }
      end
    end


    context 'a course collection proxy' do
      let(:collection_proxy) { CourseCollectionSolrProxy.new(id: 'foo:bar') }
      it { should_not be_able_to(:append_to, collection_proxy) }
      it { should_not be_able_to(:remove_from, collection_proxy) }
    end
  end


  describe "a non-authenticated user" do
    let(:not_logged_in) { User.new }
    subject { Ability.new(not_logged_in) }

    it { should_not be_able_to(:download, datastream) }
    it { should_not be_able_to(:create, CourseCollection) }
    it { should_not be_able_to(:append_to, course_collection) }
    it { should_not be_able_to(:remove_from, course_collection) }
    it { should_not be_able_to(:show, course_collection) }
    it { should_not be_able_to(:create, PersonalCollection) }
    it { should_not be_able_to(:show, personal_collection) }
    it { should_not be_able_to(:append_to, personal_collection) }
    it { should_not be_able_to(:show, image) }
  end
end
