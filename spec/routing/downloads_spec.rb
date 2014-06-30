require 'rails_helper'

describe 'Downloads routes:' do
  it 'routes to show' do
    expect(get: 'downloads/1').to route_to(
      controller: 'downloads',
      action: 'show',
      id: '1'
    )
  end
end
