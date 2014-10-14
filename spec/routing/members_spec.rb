require 'rails_helper'

describe 'Course Collection Members' do
  it 'routes to show' do
    expect(get: 'course_collections/tufts.uc:1/members/1').to route_to(
      controller: 'members', action: 'show', course_collection_id: 'tufts.uc:1', id: '1')
  end
end

describe 'Personal Collection Members' do
  it 'routes to show' do
    expect(get: 'personal_collections/tufts.uc:test.000.01/members/1').to route_to(
      controller: 'members', action: 'show', personal_collection_id: 'tufts.uc:test.000.01', id: '1')
  end
end

