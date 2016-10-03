require 'rails_helper'

RSpec.describe "meters/show", type: :view do
  before(:each) do
    @meter = assign(:meter, Meter.create!(
      :school => nil,
      :type => 2,
      :meter_no => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
