require 'rails_helper'

describe 'Course Collections' do

  it 'routes to show' do
    expect(get: 'course_collections/tufts.uc:1').to route_to(controller: 'course_collections', action: 'show', id: 'tufts.uc:1')
  end

  it 'routes to show' do
    expect(get: 'course_collections/tufts.uc:1.pptx').to route_to(controller: 'course_collections', action: 'show', id: 'tufts.uc:1', format: 'pptx')
  end

  it 'routes to new' do
    expect(get: 'course_collections/new').to route_to(controller: 'course_collections', action: 'new')
  end

  it 'routes to edit' do
    expect(get: 'course_collections/tufts.uc:test.000.01/edit').to route_to(
      controller: 'course_collections', action: 'edit', id: 'tufts.uc:test.000.01')
  end

  it 'routes to update' do
    expect(patch: 'course_collections/1').to route_to(
      controller: 'course_collections', action: 'update', id: '1')
  end

  it 'routes to update_type' do
    expect(patch: 'course_collections/1/update_type').to route_to(
      controller: 'course_collections', action: 'update_type', id: '1')
  end

  it 'routes to create' do
    expect(post: 'course_collections').to route_to(controller: 'course_collections', action: 'create')
  end

  it 'routes to destroy' do
    expect(delete: 'course_collections/1').to route_to(
      controller: 'course_collections', action: 'destroy', id: '1')
  end

  it 'routes to append_to' do
    expect(patch: 'course_collections/1/append_to').to route_to(
      controller: 'course_collections', action: 'append_to', id: '1'
    )
  end

  it 'routes to remove_from' do
    expect(delete: 'course_collections/1/remove_from').to route_to(
      controller: 'course_collections', action: 'remove_from', id: '1'
    )
  end

end

describe 'Personal Collections' do

  it 'routes to show' do
    expect(get: 'personal_collections/tufts.uc:test.000.01').to route_to(
      controller: 'personal_collections', action: 'show', id: 'tufts.uc:test.000.01')
  end

  it 'routes to new' do
    expect(get: 'personal_collections/new').to route_to( controller: 'personal_collections', action: 'new')
  end

  it 'routes to edit' do
    expect(get: 'personal_collections/1/edit').to route_to(
      controller: 'personal_collections', action: 'edit', id: '1')
  end

  it 'routes to update' do
    expect(patch: 'personal_collections/1').to route_to(
      controller: 'personal_collections', action: 'update', id: '1')
  end

  it 'routes to update_type' do
    expect(patch: 'personal_collections/1/update_type').to route_to(
      controller: 'personal_collections', action: 'update_type', id: '1')
  end

  it 'routes to create' do
    expect(post: 'personal_collections').to route_to(
      controller: 'personal_collections', action: 'create')
  end

  it 'routes to destroy' do
    expect(delete: 'course_collections/1').to route_to(
      controller: 'course_collections', action: 'destroy', id: '1')
  end

  it 'routes to append_to' do
    expect(patch: 'personal_collections/1/append_to').to route_to(
      controller: 'personal_collections', action: 'append_to', id: '1' )
  end

  it 'routes to remove_from' do
    expect(delete: 'personal_collections/1/remove_from').to route_to(
      controller: 'personal_collections', action: 'remove_from', id: '1'
    )
  end
end

