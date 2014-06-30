require 'rails_helper'
require "cancan/matchers"

describe Ability do
  before :all do
    User.delete_all
  end
  let(:user) { FactoryGirl.create(:user) }

  describe "a non-admin user" do
    subject { Ability.new(user) }
    it { should be_able_to(:download, ActiveFedora::Datastream) }
  end

  describe "a non-authenticated user" do
    let(:not_logged_in) { User.new }
    subject { Ability.new(not_logged_in) }

    it { should_not be_able_to(:download, ActiveFedora::Datastream) }
  end
end
