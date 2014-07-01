require 'rails_helper'

RSpec.describe User, :type => :model do

  it 'by default has the role of a registered user (after it is saved)' do
    user = FactoryGirl.build(:user)
    expect(user.registered?).to be_falsey
    user.save
    expect(user.registered?).to be_truthy
  end

end
