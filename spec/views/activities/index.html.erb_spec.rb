require 'rails_helper'

RSpec.describe "activities/index", type: :view do
  before(:each) do
    assign(:activities, [
      Activity.create!(
        :school => nil,
        :activity_type => nil,
        :title => "Title",
        :description => "MyText"
      ),
      Activity.create!(
        :school => nil,
        :activity_type => nil,
        :title => "Title",
        :description => "MyText"
      )
    ])
  end

  it "renders a list of activities" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
