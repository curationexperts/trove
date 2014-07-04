require 'rails_helper'

describe 'Pages routes:' do
  it 'routes to about' do
    expect(get: 'about').to route_to(
      controller: 'pages',
      action: 'about'
    )
  end

  it 'routes to contact' do
    expect(get: 'contact').to route_to(
      controller: 'pages',
      action: 'contact'
    )
  end
end
