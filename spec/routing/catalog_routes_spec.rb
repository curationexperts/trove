require 'rails_helper'

describe "catalog routes" do

  it 'routes to show' do
    expect(get: 'catalog/tufts.uc:test.000.01').to route_to(
      controller: 'catalog', action: 'show', id: 'tufts.uc:test.000.01')
  end

  it 'routes to add_to_collection' do
    expect(patch: 'catalog/tufts.uc:test.000.01/add_to_collection').to route_to(
      controller: 'catalog', action: 'add_to_collection', id: 'tufts.uc:test.000.01')
  end

end
