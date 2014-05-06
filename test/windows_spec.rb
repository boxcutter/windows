require_relative 'spec_helper'

describe 'windows box' do
  it 'should have a vagrant user' do
    expect(user 'vagrant').to exist
  end
end
