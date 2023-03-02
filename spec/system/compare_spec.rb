require 'rails_helper'

describe 'compare pages', type: :system do

  shared_examples "a compare search header" do |intro: |
    it "has standard header information" do
      expect(page).to have_content "School Comparison Tool"
      expect(page).to have_content "Identify examples of best practice"
      expect(page).to have_content intro
    end
  end

  shared_examples "a compare search filter page" do |tab: |
    it "has tabbed navigation" do
      expect(page).to have_link("Your group", href: '/compare/group')
      expect(page).to have_link("Choose categories")
      expect(page).to have_link("Choose groups")
    end

    it "#{tab} tab is selected" do
      expect(page).to have_css("a.nav-link.active", text: tab)
    end
  end

  before do
    visit compare_path
  end

  it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
  it_behaves_like "a compare search filter page", tab: 'Your group'

  context "'Your group' filter page" do
    before { click_on 'Your group' }

    it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
    it_behaves_like "a compare search filter page", tab: 'Your group'

  end

  context "'Categories' filter page" do
    before { click_on 'Choose categories' }

    it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
    it_behaves_like "a compare search filter page", tab: 'Choose categories'
  end

  context "'Groups' filter page" do
    before { click_on 'Choose groups' }

    it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
    it_behaves_like "a compare search filter page", tab: 'Choose groups'
  end
end
