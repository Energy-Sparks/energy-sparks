require 'rails_helper'

RSpec.describe "meters/edit", type: :view do
  before(:each) do
    @meter = assign(:meter, Meter.create!(
      :school => nil,
      :type => 1,
      :meter_no => 1
    ))
  end

  it "renders the edit meter form" do
    render

    assert_select "form[action=?][method=?]", meter_path(@meter), "post" do

      assert_select "input#meter_school_id[name=?]", "meter[school_id]"

      assert_select "input#meter_type[name=?]", "meter[type]"

      assert_select "input#meter_meter_no[name=?]", "meter[meter_no]"
    end
  end
end
