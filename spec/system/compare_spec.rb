require 'rails_helper'

shared_examples "a compare search header" do |intro: |
  it "has standard header information" do
    expect(page).to have_content "School Comparison Tool"
    expect(page).to have_content "Identify examples of best practice"
    expect(page).to have_content intro
  end
end

shared_examples "a compare search filter page" do |tab:, show_your_group_tab:true|
  it "has standard tabs" do
    expect(page).to have_link("Choose categories", href: '/compare/categories')
    expect(page).to have_link("Choose groups", href: '/compare/groups')
  end

  it "has 'Your group' tab", if: show_your_group_tab do
    expect(page).to have_link("Your group", href: '/compare/group')
  end

  it "doesn't have 'Your group' tab", unless: show_your_group_tab do
    expect(page).to_not have_link("Your group", href: '/compare/group')
  end

  it "#{tab} tab is selected" do
    expect(page).to have_css("a.nav-link.active", text: tab)
  end
end

describe 'compare pages', type: :system do

  before do
    sign_in(user) if user
    visit compare_path
  end

  context "Logged in user with school group" do
    let(:user) { create(:user, school_group: create(:school_group)) }

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

  context "Logged in user withought school group" do
    let(:user) { create(:admin) }

    it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
    it_behaves_like "a compare search filter page", tab: 'Choose categories', show_your_group_tab: false
  end

  context "Logged out user" do
    let(:user) {}

    it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
    it_behaves_like "a compare search filter page", tab: 'Choose categories', show_your_group_tab: false
  end

end
