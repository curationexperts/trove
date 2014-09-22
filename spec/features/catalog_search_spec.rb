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

  context "when displays are set" do
    let!(:tdil_obj) { create(:image, displays: ['dl', 'tdil']) }
    let!(:non_tdil_obj) { create(:image, displays: ['dl']) }

    scenario 'returns only objects with "tdil" display' do
      puts "tdil_obj #{tdil_obj.pid}"
      puts "non_tdil_obj #{non_tdil_obj.pid}"
      visit root_path
      click_button('Search')
      within('#documents') do
        expect(page).to     have_content(tdil_obj.title)
        expect(page).to_not have_content(non_tdil_obj.title)
      end
    end
  end

end
