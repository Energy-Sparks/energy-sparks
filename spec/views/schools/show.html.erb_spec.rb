require 'rails_helper'

RSpec.describe "schools/show", type: :view do
  before(:each) do
    @school = assign(:school, School.create!(
      :name => "Name",
      :type => 2,
      :address => "MyText",
      :postcode => "Postcode",
      :eco_school_status => 3,
      :website => "Website"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Postcode/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Website/)
  end
end
