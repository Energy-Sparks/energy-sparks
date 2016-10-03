require 'rails_helper'

RSpec.describe "schools/new", type: :view do
  before(:each) do
    assign(:school, School.new(
      :name => "MyString",
      :type => 1,
      :address => "MyText",
      :postcode => "MyString",
      :eco_school_status => 1,
      :website => "MyString"
    ))
  end

  it "renders new school form" do
    render

    assert_select "form[action=?][method=?]", schools_path, "post" do

      assert_select "input#school_name[name=?]", "school[name]"

      assert_select "input#school_type[name=?]", "school[type]"

      assert_select "textarea#school_address[name=?]", "school[address]"

      assert_select "input#school_postcode[name=?]", "school[postcode]"

      assert_select "input#school_eco_school_status[name=?]", "school[eco_school_status]"

      assert_select "input#school_website[name=?]", "school[website]"
    end
  end
end
