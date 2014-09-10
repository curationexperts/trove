require 'rails_helper'

describe 'Downloads routes:' do
  it 'routes to show' do
    expect(get: 'downloads/tufts.uc:test.000.01').to route_to(
      controller: 'downloads',
      action: 'show',
      id: 'tufts.uc:test.000.01'
    )
  end
end
