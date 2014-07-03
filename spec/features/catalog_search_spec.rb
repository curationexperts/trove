require 'rails_helper'

feature 'Catalog Search:' do
  let(:user) { FactoryGirl.create(:user) }

  before do
    ActiveFedora::Base.delete_all
    sign_in(user)
  end

  scenario 'returns only course collections, not personal collections' do
    FactoryGirl.create(:course_collection, title: 'Course Collection AAA', user: user)
    FactoryGirl.create(:personal_collection, title: 'Personal Collection AAA', user: user)

    visit root_path
    fill_in 'q', with: 'AAA'
    click_button('Search')
    within('#documents') do
      expect(page).to     have_content('Course Collection AAA')
      expect(page).to_not have_content('Personal Collection AAA')
    end
  end

  scenario 'returns only objects with "tdil" display' do
    tdil_obj = FactoryGirl.create(:image, displays: ['dl', 'tdil'])
    non_tdil_obj = FactoryGirl.create(:image, displays: ['dl'])

    visit root_path
    click_button('Search')
    within('#documents') do
      expect(page).to     have_content(tdil_obj.title)
      expect(page).to_not have_content(non_tdil_obj.title)
    end
  end

end
