require 'rails_helper'

RSpec.describe 'API routes' do
  it 'routes alphanumeric tags for app deployment' do
    expect(post: '/api/app/1/deploy/latest').to be_routable
  end

  it 'routes valid non-alphanumeric tags for app deployment' do
    expect(post: '/api/app/1/deploy/v1.0.0-BETA_r1').to be_routable
  end

  it 'does not route invalid tags longer than 128 characters for app deployment' do
    expect(post: '/api/app/1/deploy/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa').to_not be_routable
  end

  it 'does not route invalid tags starting with a period for app deployment' do
    expect(post: '/api/app/1/deploy/.invalid').to_not be_routable
  end

  it 'does not route invalid tags starting with a dash for app deployment' do
    expect(post: '/api/app/1/deploy/-invalid').to_not be_routable
  end
end
