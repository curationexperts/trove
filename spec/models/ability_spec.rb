require 'rails_helper'
require "cancan/matchers"

describe Ability do
  before :all do
    User.delete_all
  end
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }


  describe "an admin user" do
    subject { Ability.new(admin) }

    it { should be_able_to(:download, ActiveFedora::Datastream) }
    it { should be_able_to(:create, CourseCollection) }
    it { should be_able_to(:append_to, CourseCollection) }
  end


  describe "a non-admin user" do
    subject { Ability.new(user) }

    it { should be_able_to(:download, ActiveFedora::Datastream) }
    it { should_not be_able_to(:create, CourseCollection) }
    it { should_not be_able_to(:append_to, CourseCollection) }
  end


  describe "a non-authenticated user" do
    let(:not_logged_in) { User.new }
    subject { Ability.new(not_logged_in) }

    it { should_not be_able_to(:download, ActiveFedora::Datastream) }
    it { should_not be_able_to(:create, CourseCollection) }
    it { should_not be_able_to(:append_to, CourseCollection) }
  end
end
