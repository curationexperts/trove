require 'rails_helper'

describe User do

  it 'by default has the role of a registered user (after it is saved)' do
    user = FactoryGirl.build(:user)
    expect(user).to_not be_registered
    user.save
    expect(user).to be_registered
  end

  describe "#personal_collection" do
    let(:user) { FactoryGirl.create(:user, email: "a%b+c++d@e.com") }
    let(:collection) { user.personal_collection(true) }

    it "generates a pid that works with fedora" do
      expect(PersonalCollection).to exist(collection.id)
    end
  end
end
