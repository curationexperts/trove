require 'rails_helper'

feature 'Copying Collections:' do
  let(:course_collection) { FactoryGirl.create(:course_collection, member_ids: [image.id]) }
  let(:image) { FactoryGirl.create(:image) }

  context 'an admin user' do
    let(:personal_collection) { FactoryGirl.create(:personal_collection) }
    let(:admin) { FactoryGirl.create(:admin) }
    before do
      CourseCollection.destroy_all
      sign_in admin
    end

    scenario 'copies a course collection' do
      visit course_collection_path(course_collection)
      expect {
        click_button('copy this collection')
      }.to change { CourseCollection.count }.by(1)
      expect(CourseCollection.root.members.map(&:members)).to eq [[image], [image]]
    end

    scenario 'copies a personal collection' do
      visit personal_collection_path(personal_collection)
      expect {
        click_button('copy this collection')
      }.to change { PersonalCollection.count }.by(2)
    end
  end

  context 'a non-admin user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:personal_collection) { FactoryGirl.create(:personal_collection, user: user) }
    before { sign_in user }

    scenario 'makes a personal copy of a course collection' do
      visit course_collection_path(course_collection)
      expect {
        click_button('copy this collection')
      }.to change { PersonalCollection.count }.by(2)
    end

    scenario 'makes a personal copy of a personal collection' do
      visit personal_collection_path(personal_collection)
      expect {
        click_button('copy this collection')
      }.to change { PersonalCollection.count }.by(1)
    end
  end

end
