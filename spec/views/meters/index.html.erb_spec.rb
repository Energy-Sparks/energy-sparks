require 'rails_helper'

RSpec.describe "meters/index", type: :view do
  before(:each) do
    assign(:meters, [
      Meter.create!(
        :school => nil,
        :type => 2,
        :meter_no => 3
      ),
      Meter.create!(
        :school => nil,
        :type => 2,
        :meter_no => 3
      )
    ])
  end

  it "renders a list of meters" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
