require 'rails_helper'

feature 'Catalog Search:' do
  let(:user) { FactoryGirl.create(:user) }

  before do
    ActiveFedora::Base.delete_all
    @cc = FactoryGirl.create(:course_collection, title: 'Course Collection AAA', user: user)
    @pc = FactoryGirl.create(:personal_collection, title: 'Personal Collection AAA', user: user)
    sign_in(user)
  end

  scenario 'returns only course collections, not personal collections' do
    visit root_path
    fill_in 'q', with: 'AAA'
    click_button('Search')
    within('#documents') do
      expect(page).to     have_content('Course Collection AAA')
      expect(page).to_not have_content('Personal Collection AAA')
    end
  end

end
