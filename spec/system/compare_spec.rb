require 'rails_helper'

describe 'compare pages', type: :system do

  shared_examples "a compare search header" do
    it "has standard header information" do
      expect(page).to have_content "School Comparison Tool"
      expect(page).to have_content "Identify examples of best practice"
    end
  end

  before do
    visit compare_path
  end

  it_behaves_like "a compare search header"

  it "has group search intro" do
    expect(page).to have_content "View how schools within the same MAT"
  end

end
