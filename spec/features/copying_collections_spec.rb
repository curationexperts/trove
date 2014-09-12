require 'rails_helper'

feature 'Copying Collections:' do
  let(:course_collection) { create(:course_collection, member_ids: [image.id]) }
  let(:image) { create(:image) }

  context 'an admin user' do
    let(:personal_collection) { create(:personal_collection) }
    let(:admin) { create(:admin) }
    before do
      PersonalCollection.destroy_all
      CourseCollection.destroy_all
      sign_in admin
    end

    scenario 'copies a course collection' do
      visit course_collection_path(course_collection)
      expect {
        click_link('copy this collection')
      }.to change { CourseCollection.count }.by(1)
      expect(CourseCollection.root.members.map(&:members)).to eq [[image], [image]]
    end

    scenario 'copies a personal collection' do
      visit personal_collection_path(personal_collection)
      expect {
        click_link('copy this collection')
      }.to change { PersonalCollection.count }.by(2) #personal root & target collection
    end
  end

  context 'a non-admin user' do
    let(:user) { create(:user) }
    let(:personal_collection) { create(:personal_collection, user: user) }
    before { sign_in user }

    scenario 'makes a personal copy of a course collection' do
      visit course_collection_path(course_collection)
      expect {
        click_link('copy this collection')
      }.to change { PersonalCollection.count }.by(2)
    end

    scenario 'makes a personal copy of a personal collection' do
      visit personal_collection_path(personal_collection)
      expect {
        click_link('copy this collection')
      }.to change { PersonalCollection.count }.by(1)
    end
  end

end
