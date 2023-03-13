require 'rails_helper'

shared_examples "a compare index page" do |tab:, show_your_group_tab:true|
  it "has standard header information" do
    expect(page).to have_content "School Comparison Tool"
    expect(page).to have_content "Identify examples of best practice"
    expect(page).to have_content "View how schools within the same MAT"
    expect(page).to have_content "Use options below to compare 1 schools against 1 benchmarks"
  end

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

shared_examples "a compare form filter" do |excluding: []|
  let(:all_school_types)  { School.school_types.keys }

  it 'has school_type checkbox fields' do
    all_school_types.excluding(excluding).each do |school_type|
      expect(page).to have_checked_field(I18n.t("common.school_types.#{school_type}"))
    end
    excluding.each do |school_type|
      expect(page).to have_unchecked_field(I18n.t("common.school_types.#{school_type}"))
    end
  end
end

shared_examples "a compare filter summary" do |excluding: []|
  let(:all_school_types)  { School.school_types.keys }

  it 'displays school type filters' do
    all_school_types.excluding(excluding).each do |school_type|
      expect(page).to have_content(I18n.t("common.school_types.#{school_type}"))
    end
    excluding.each do |school_type|
      expect(page).to_not have_content(I18n.t("common.school_types.#{school_type}"))
    end
  end
  it { expect(page).to have_link('Change options')}
end

shared_context 'a compare index page context' do
  before do
    expect(Benchmarking::BenchmarkManager).to receive(:structured_pages).at_least(:once).and_return(benchmark_groups)
  end
end

shared_context 'a compare benchmarks page context' do
  let(:content_manager)   { double(:content_manager) }
  let!(:benchmark_run)    { BenchmarkResultSchoolGenerationRun.create(school: school, benchmark_result_generation_run: BenchmarkResultGenerationRun.create! ) }

  before do
    expect(Benchmarking::BenchmarkContentManager).to receive(:new).at_least(:once).and_return(content_manager)
    expect(content_manager).to receive(:structured_pages).at_least(:once).and_return(benchmark_groups)
  end
end

shared_context 'a compare results page context' do
  # include_context 'a compare benchmarks page context'
  let(:description) { 'all about this alert type' }
  let!(:gas_fuel_alert_type) { create(:alert_type, source: :analysis, sub_category: :heating, fuel_type: :gas, description: description, frequency: :weekly) }
  let(:example_content) {
    [
      { type: :title, content: 'Benchmark name'},
      { type: :html, content: 'HTML'},
      { type: :chart, content: { title: 'chart title', config_name: "config_name", x_axis: ["a school"] } },
      { type: :table_composite, content: { header: ['table composite header'], rows: [[{ formatted: 'row 1', raw: 'row 1'}], [{ formatted: school.name, urn: school.urn, drilldown_content_class: gas_fuel_alert_type.class_name }]] }},
      { type: :table_text, content: 'table text'},
      { type: :analytics_html, content: 'analytics html'},
      { type: :chart_data, content: 'chart data'}
    ]
  }

  before do
    expect(content_manager).to receive(:content).at_least(:once).and_return(example_content)
  end
end

describe 'compare pages', :compare, type: :system do
  let(:school_group)      { create(:school_group) }
  let!(:school)           { create(:school, school_group: school_group)}
  let(:benchmark_groups)  { [ { name: 'Benchmark group name', description: 'Benchmark description', benchmarks: { a_benchmark_key: 'Benchmark name'} } ] }

  include_context "a compare index page context"

  before do
    sign_in(user) if user
    visit compare_index_path
  end

  context "Logged in user with school group" do
    let(:user) { create(:user, school_group: school_group) }

    it_behaves_like "a compare index page", tab: 'Your group'

    context "'Your group' filter tab" do
      before { click_on 'Your group' }

      it_behaves_like "a compare index page", tab: 'Your group'
      it { expect(page).to have_content "Compare all schools within #{user.school_group_name}" }

      context "search filter" do
        it_behaves_like "a compare form filter"
        context "Benchmark page" do
          include_context 'a compare benchmarks page context'
          before do
            within '#group' do
              uncheck 'Junior', allow_label_click: true
              click_on 'Compare schools'
            end
          end

          it_behaves_like "a compare filter summary", excluding: ['junior']

          context "Changing options" do
            before { click_on "Change options" }
            it_behaves_like "a compare index page", tab: 'Your group'
            it_behaves_like "a compare form filter", excluding: ['junior']
          end

          it { expect(page).to have_content('Benchmark group name') }
          it { expect(page).to have_content('Benchmark description') }
          it { expect(page).to have_link('Benchmark name') }

          context "results page" do
            include_context 'a compare results page context'
            before do
              click_on 'Benchmark name'
            end

            it { expect(page).to have_selector('h1', text: 'Benchmark name') }
            it_behaves_like "a compare filter summary", excluding: ['junior']
            context "Changing options" do
              before { click_on "Change options" }
              it_behaves_like "a compare index page", tab: 'Your group'
              it_behaves_like "a compare form filter", excluding: ['junior']
            end

            it "has included fragments" do
              within '#benchmark-content' do
                expect(page).to have_content('HTML')
                expect(page).to have_content('table composite header')
                expect(page).to have_css("div#chart_config_name.analysis-chart")
              end
            end

            it "excludes fragments" do
              within '#benchmark-content' do
                expect(page).to_not have_content('table text')
                expect(page).to_not have_content('analytics html')
                expect(page).to_not have_content('chart data')
              end
            end
          end
        end
      end
    end

    context "'Categories' filter tab" do
      before { click_on 'Choose categories' }

      it_behaves_like "a compare index page", tab: 'Choose categories'
    end

    context "'Groups' filter tab" do
      before { click_on 'Choose groups' }

      it_behaves_like "a compare index page", tab: 'Choose groups'
    end
  end

  context "Logged in user without school group" do
    let(:user) { create(:admin) }

    it_behaves_like "a compare index page", tab: 'Choose categories', show_your_group_tab: false
  end

  context "Logged out user" do
    let(:user) {}
    it_behaves_like "a compare index page", tab: 'Choose categories', show_your_group_tab: false
  end

end
