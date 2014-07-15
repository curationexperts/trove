require 'rails_helper'

feature 'Copying Collections:' do
  let(:course_collection) { FactoryGirl.create(:course_collection) }
  let(:personal_collection) { FactoryGirl.create(:personal_collection) }

  context 'an admin user' do
    let(:admin) { FactoryGirl.create(:admin) }
    before { sign_in admin }

    scenario 'copies a course collection' do
      visit course_collection_path(course_collection)
      expect {
        click_button('copy this collection')
      }.to change { CourseCollection.count }.by(1)
    end

    scenario 'copies a personal collection' do
      visit personal_collection_path(personal_collection)
      expect {
        click_button('copy this collection')
      }.to change { PersonalCollection.count }.by(1)
    end
  end

  context 'a non-admin user' do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    scenario 'makes a personal copy of a course collection' do
      visit course_collection_path(course_collection)
      expect {
        click_button('copy this collection')
      }.to change { PersonalCollection.count }.by(1)
    end

    scenario 'makes a personal copy of a personal collection' do
      visit personal_collection_path(personal_collection)
      expect {
        click_button('copy this collection')
      }.to change { PersonalCollection.count }.by(1)
    end
  end

end
