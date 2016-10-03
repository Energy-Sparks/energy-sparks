require 'rails_helper'

RSpec.describe "meters/new", type: :view do
  before(:each) do
    assign(:meter, Meter.new(
      :school => nil,
      :type => 1,
      :meter_no => 1
    ))
  end

  it "renders new meter form" do
    render

    assert_select "form[action=?][method=?]", meters_path, "post" do

      assert_select "input#meter_school_id[name=?]", "meter[school_id]"

      assert_select "input#meter_type[name=?]", "meter[type]"

      assert_select "input#meter_meter_no[name=?]", "meter[meter_no]"
    end
  end
end
