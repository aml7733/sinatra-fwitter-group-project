require 'spec_helper'

describe 'Coach' do
  before do
    @coach = Coach.create(:name => "test 123", :password => "test")
  end
  it 'can slug the coach name' do
    expect(@coach.slug).to eq("test-123")
  end

  it 'can find a coach based on the slug' do
    slug = @coach.slug
    expect(User.find_by_slug(slug).username).to eq("test 123")
  end

  it 'has a secure password' do

    expect(@coach.authenticate("dog")).to eq(false)
    expect(@coach.authenticate("test")).to eq(@coach)

  end
end
