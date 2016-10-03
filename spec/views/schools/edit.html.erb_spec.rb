require 'rails_helper'

RSpec.describe "schools/edit", type: :view do
  before(:each) do
    @school = assign(:school, School.create!(
      :name => "MyString",
      :type => 1,
      :address => "MyText",
      :postcode => "MyString",
      :eco_school_status => 1,
      :website => "MyString"
    ))
  end

  it "renders the edit school form" do
    render

    assert_select "form[action=?][method=?]", school_path(@school), "post" do

      assert_select "input#school_name[name=?]", "school[name]"

      assert_select "input#school_type[name=?]", "school[type]"

      assert_select "textarea#school_address[name=?]", "school[address]"

      assert_select "input#school_postcode[name=?]", "school[postcode]"

      assert_select "input#school_eco_school_status[name=?]", "school[eco_school_status]"

      assert_select "input#school_website[name=?]", "school[website]"
    end
  end
end
