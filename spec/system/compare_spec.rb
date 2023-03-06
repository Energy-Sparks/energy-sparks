require 'rails_helper'

shared_examples "a compare search header" do |intro: |
  it "has standard header information" do
    expect(page).to have_content "School Comparison Tool"
    expect(page).to have_content "Identify examples of best practice"
    expect(page).to have_content intro
    expect(page).to have_content "Use options below to compare 1 schools against 1 benchmarks"
  end
end

shared_examples "a compare search filter page" do |tab:, show_your_group_tab:true|
  it "has standard tabs" do
    expect(page).to have_link("Choose categories", href: '#categories')
    expect(page).to have_link("Choose groups", href: '#groups')
  end

  it "has 'Your group' tab", if: show_your_group_tab do
    expect(page).to have_link("Your group", href: '#group')
  end

  it "doesn't have 'Your group' tab", unless: show_your_group_tab do
    expect(page).to_not have_link("Your group", href: '#group')
  end

  it "#{tab} tab is selected", js: true do
    expect(page).to have_css("a.nav-link.active", text: tab)
  end
end

describe 'compare pages', :compare, type: :system do
  let(:school_group)      { create(:school_group) }
  let!(:school)           { create(:school, school_group: school_group)}
  let(:benchmark_groups)  { [ { name: 'cat1', benchmarks: { page_a: 'Page A'} } ] }

  before do
    expect(Benchmarking::BenchmarkManager).to receive(:structured_pages).at_least(:once).and_return(benchmark_groups)
    sign_in(user) if user
    visit compare_path
  end

  context "Logged in user with school group" do
    let(:user) { create(:user, school_group: school_group) }

    it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
    it_behaves_like "a compare search filter page", tab: 'Your group'

    context "'Your group' filter tab" do
      before { click_on 'Your group' }

      it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
      it_behaves_like "a compare search filter page", tab: 'Your group'
      it { expect(page).to have_content "Compare all schools within #{user.school_group_name}" }

      context "search filter" do
        it 'has a checked checkbox for each school type' do
          School.school_types.keys.each do |school_type|
            expect(page).to have_checked_field(I18n.t("common.school_types.#{school_type}"))
          end
        end
        it { expect(page).to have_button "Compare schools" }
      end
    end

    context "'Categories' filter tab" do
      before { click_on 'Choose categories' }

      it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
      it_behaves_like "a compare search filter page", tab: 'Choose categories'
    end

    context "'Groups' filter tab" do
      before { click_on 'Choose groups' }

      it_behaves_like "a compare search header", intro: "View how schools within the same MAT"
      it_behaves_like "a compare search filter page", tab: 'Choose groups'
    end
  end

  context "Logged in user without school group" do
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
