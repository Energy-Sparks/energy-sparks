require 'rails_helper'

RSpec.describe "activities/new", type: :view do
  before(:each) do
    assign(:activity, Activity.new(
      :school => nil,
      :activity_type => nil,
      :title => "MyString",
      :description => "MyText"
    ))
  end

  it "renders new activity form" do
    render

    assert_select "form[action=?][method=?]", activities_path, "post" do

      assert_select "input#activity_school_id[name=?]", "activity[school_id]"

      assert_select "input#activity_activity_type_id[name=?]", "activity[activity_type_id]"

      assert_select "input#activity_title[name=?]", "activity[title]"

      assert_select "textarea#activity_description[name=?]", "activity[description]"
    end
  end
end
