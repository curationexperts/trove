require 'rails_helper'

describe 'Course Collections' do

  it 'routes to show' do
    expect(get: 'course_collections/1').to route_to(controller: 'course_collections', action: 'show', id: '1')
  end

  it 'routes to new' do
    expect(get: 'course_collections/new').to route_to(controller: 'course_collections', action: 'new')
  end

  it 'routes to edit' do
    expect(get: 'course_collections/1/edit').to route_to(
      controller: 'course_collections', action: 'edit', id: '1')
  end

  it 'routes to create' do
    expect(post: 'course_collections').to route_to(controller: 'course_collections', action: 'create')
  end

  it 'routes to append_to' do
    expect(patch: 'course_collections/1/append_to').to route_to(
      controller: 'course_collections', action: 'append_to', id: '1' 
    )   
  end 

end

describe 'Personal Collections' do

  it 'routes to show' do
    expect(get: 'personal_collections/1').to route_to(
      controller: 'personal_collections', action: 'show', id: '1')
  end

  it 'routes to new' do
    expect(get: 'personal_collections/new').to route_to( controller: 'personal_collections', action: 'new')
  end

  it 'routes to edit' do
    expect(get: 'personal_collections/1/edit').to route_to(
      controller: 'personal_collections', action: 'edit', id: '1')
  end

  it 'routes to create' do
    expect(post: 'personal_collections').to route_to(
      controller: 'personal_collections', action: 'create')
  end

  it 'routes to append_to' do
    expect(patch: 'personal_collections/1/append_to').to route_to(
      controller: 'personal_collections', action: 'append_to', id: '1' )   
  end 
end

