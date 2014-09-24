require 'rails_helper'

describe User do

  describe "#personal_collection" do
    let(:user) { FactoryGirl.create(:user, email: "a%b+c++d@e.com") }
    let(:collection) { user.personal_collection(true) }

    it "generates a pid that works with fedora" do
      expect(PersonalCollection).to exist(collection.id)
    end
  end
end
