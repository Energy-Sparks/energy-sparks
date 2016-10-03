require 'rails_helper'

RSpec.describe "schools/index", type: :view do
  before(:each) do
    assign(:schools, [
      School.create!(
        :name => "Name",
        :type => 2,
        :address => "MyText",
        :postcode => "Postcode",
        :eco_school_status => 3,
        :website => "Website"
      ),
      School.create!(
        :name => "Name",
        :type => 2,
        :address => "MyText",
        :postcode => "Postcode",
        :eco_school_status => 3,
        :website => "Website"
      )
    ])
  end

  it "renders a list of schools" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Postcode".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "Website".to_s, :count => 2
  end
end
