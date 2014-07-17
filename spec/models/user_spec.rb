require 'rails_helper'

RSpec.describe User, :type => :model do

  it 'by default has the role of a registered user (after it is saved)' do
    user = FactoryGirl.build(:user)
    expect(user).to_not be_registered
    user.save
    expect(user).to be_registered
  end

  it "generates a pid that works with fedora" do
    user = FactoryGirl.create(:user, email: "a%b+c++d@e.com")
    root_pid = user.personal_collection_proxy.id
    expect(PersonalCollection.exists?(root_pid)).to eq true
  end
end
