require 'rails_helper'

describe 'compare pages', :compare, type: :system do
  shared_examples "an index page" do |tab:, show_your_group_tab: true|
    it "has standard header information" do
      expect(page).to have_content "School Comparison Tool"
      expect(page).to have_content "Identify examples of best practice"
      expect(page).to have_content "View how schools within the same MAT"
      expect(page).to have_content "Use options below to compare 2 schools against 1 benchmarks"
    end

    it "has standard tabs" do
      expect(page).to have_link("Choose country", href: '#country')
      expect(page).to have_link("Choose type", href: '#type')
      expect(page).to have_link("Choose groups", href: '#groups')
    end

    it "has 'Your group' tab", if: show_your_group_tab do
      expect(page).to have_link("Your group", href: '#group')
    end

    it "doesn't have 'Your group' tab", unless: show_your_group_tab do
      expect(page).not_to have_link("Your group", href: '#group')
    end

    it "#{tab} tab is selected", js: true do
      expect(page).to have_css("a.nav-link.active", text: tab)
    end
  end

  shared_examples "a benchmark list page" do
    it { expect(page).to have_content('Benchmark group name') }
    it { expect(page).to have_content('Benchmark description') }
    it { expect(page).to have_link('Benchmark name') }
  end

  shared_examples "a results page" do
    it { expect(page).to have_selector('h1', text: 'Benchmark name') }

    it "has included fragments" do
      within '#intro' do
        expect(page).not_to have_content('Benchmark name')
        expect(page).to have_content('intro html')
      end

      within '#tables' do
        expect(page).to have_content('table composite header')
        expect(page).to have_content('table html')
        expect(page).to have_content('Benchmark 2')
        expect(page).to have_content('table composite 2 header')
        expect(page).to have_content('table html')
      end

      within '#charts' do
        expect(page).to have_css("div#chart_config_name.analysis-chart")
        expect(page).to have_content('chart html')
      end
    end

    it "excludes fragments" do
      within '#tables' do
        expect(page).not_to have_content('table text')
        expect(page).not_to have_content('analytics html')
        expect(page).not_to have_content('chart data')
      end
    end

    it { expect(page).to have_link('Change benchmark') }
  end

  shared_examples "a form filter" do |id:, school_types_excluding: nil, school_type: nil, country: nil, funder: nil, school_groups: nil|
    let(:all_school_types) { School.school_types.keys }

    it 'has school_type checkbox fields', if: school_types_excluding do
      within id.to_s do
        all_school_types.excluding(school_types_excluding).each do |type|
          expect(page).to have_checked_field(I18n.t("common.school_types.#{type}"))
        end
        school_types_excluding.each do |type|
          expect(page).to have_unchecked_field(I18n.t("common.school_types.#{type}"))
        end
      end
    end

    it "has school type select", if: school_type do
      within id.to_s do
        expect(page).to have_select('school_type', selected: school_type)
      end
    end

    it "has country radio buttons", if: country do
      within id.to_s do
        expect(page).to have_checked_field(country)
      end
    end

    it "has funder select", if: funder do
      within id.to_s do
        expect(page).to have_select('funder', selected: funder)
      end
    end

    it "has school group select", if: school_groups do
      within id.to_s do
        expect(page).to have_select('school_group_ids', selected: school_groups)
      end
    end
  end

  shared_examples "a filter summary" do |school_types: nil, school_types_excluding: nil, country: nil, school_groups: nil, funder: nil|
    let(:all_school_types)  { School.school_types.keys }

    it 'displays school types', if: school_types do
      school_types.each do |school_type|
        expect(page).to have_content(I18n.t("common.school_types.#{school_type}"))
      end
      all_school_types.excluding(school_types).each do |school_type|
        expect(page).not_to have_content(I18n.t("common.school_types.#{school_type}"))
      end
    end

    it 'displays school types', if: school_types_excluding do
      all_school_types.excluding(school_types_excluding).each do |school_type|
        expect(page).to have_content(I18n.t("common.school_types.#{school_type}"))
      end
      school_types_excluding.each do |school_type|
        expect(page).not_to have_content(I18n.t("common.school_types.#{school_type}"))
      end
    end

    it 'displays country', if: country do
      expect(page).to have_content country
    end

    it 'displays groups', if: school_groups do
      school_groups.each do |group|
        expect(page).to have_content(group)
      end
    end

    it 'displays funder', if: funder do
      expect(page).to have_content funder
    end

    it { expect(page).to have_link('Change options')}
  end

  ## contexts ##

  shared_context 'index page context' do
    before do
      expect(Benchmarking::BenchmarkManager).to receive(:structured_pages).at_least(:once).and_return(benchmark_groups)
    end
  end

  shared_context 'benchmarks page context' do
    let(:content_manager)   { double(:content_manager) }
    let!(:benchmark_run)    { BenchmarkResultSchoolGenerationRun.create(school: school, benchmark_result_generation_run: BenchmarkResultGenerationRun.create!) }

    before do
      expect(Benchmarking::BenchmarkContentManager).to receive(:new).at_least(:once).and_return(content_manager)
      expect(content_manager).to receive(:structured_pages).at_least(:once).and_return(benchmark_groups)
    end
  end

  shared_context 'results page context' do
    let(:description) { 'all about this alert type' }
    let!(:gas_fuel_alert_type) { create(:alert_type, source: :analysis, sub_category: :heating, fuel_type: :gas, description: description, frequency: :weekly) }
    let(:example_content) do
      [
        { type: :title, content: 'Benchmark name' },
        { type: :html, content: 'intro html' },
        { type: :chart, content: { title: 'chart title', config_name: "config_name", x_axis: ["a school"] } },
        { type: :html, content: 'chart html' },
        { type: :table_composite, content: { header: ['table composite header'], rows: [[{ formatted: 'row 1', raw: 'row 1' }], [{ formatted: school.name, urn: school.urn, drilldown_content_class: gas_fuel_alert_type.class_name }]] } },
        { type: :table_text, content: 'table text' },
        { type: :html, content: 'table html' },
        { type: :analytics_html, content: 'analytics html' },
        { type: :title, content: 'Benchmark 2' },
        { type: :table_composite, content: { header: ['table composite 2 header'], rows: [[{ formatted: 'row 1', raw: 'row 1' }], [{ formatted: school.name, urn: school.urn, drilldown_content_class: gas_fuel_alert_type.class_name }]] } },
        { type: :html, content: 'table 2 html' },
      ]
    end

    before do
      expect(content_manager).to receive(:content).at_least(:once).and_return(example_content)
    end
  end

  ## tests ##

  let(:user) {}
  let(:all_school_types) { School.school_types.keys }
  let!(:funder)          { create(:funder, name: "Grant Funder") }
  let!(:school_group)    { create(:school_group, name: "Group 1") }
  let!(:school)          { create(:school, school_group: school_group, funder: funder)}
  let!(:school_group_2)  { create(:school_group, name: "Group 2") }
  let!(:school_2)        { create(:school, school_group: school_group_2)}

  let(:benchmark_groups) { [{ name: 'Benchmark group name', description: 'Benchmark description', benchmarks: { a_benchmark_key: 'Benchmark name' } }] }

  include_context "index page context"

  before do
    sign_in(user) if user
    visit compare_index_path
  end

  context "Logged in user with school group" do
    let(:user) { create(:user, school_group: school_group) }

    it_behaves_like "an index page", tab: 'Your group'

    context "'Your group' filter tab" do
      before { click_on 'Your group' }

      it_behaves_like "an index page", tab: 'Your group'
      it { expect(page).to have_content "Compare all schools within #{user.school_group_name}" }
      it_behaves_like "a form filter", id: '#group', school_types_excluding: [] # show all

      context "Benchmark page" do
        include_context 'benchmarks page context'
        before do
          within '#group' do
            uncheck 'Junior'
            click_on 'Compare schools'
          end
        end

        it_behaves_like "a benchmark list page"
        it_behaves_like "a filter summary", school_types_excluding: ['junior']

        context "Changing options" do
          before { click_on "Change options" }

          it_behaves_like "an index page", tab: 'Your group'
          it_behaves_like "a form filter", id: '#group', school_types_excluding: ['junior']
        end

        context "results page" do
          include_context 'results page context'
          before { click_on 'Benchmark name' }

          it_behaves_like "a results page"
          it_behaves_like "a filter summary", school_types_excluding: ['junior']

          context "Changing options" do
            before { click_on "Change options" }

            it_behaves_like "an index page", tab: 'Your group'
            it_behaves_like "a form filter", id: '#group', school_types_excluding: ['junior']
          end
        end
      end
    end

    context "'Country' filter tab" do
      before { click_on 'Choose country' }

      it_behaves_like "an index page", tab: 'Choose country'
      it { expect(page).to have_content "Compare schools by country" }

      it_behaves_like "a form filter", id: '#country', country: "All countries"

      context "Benchmark page" do
        include_context 'benchmarks page context'
        before do
          within '#country' do
            choose 'Scotland'
            uncheck 'Middle'
            click_on 'Compare schools'
          end
        end

        it_behaves_like "a benchmark list page"
        it_behaves_like "a filter summary", country: "Scotland", school_types_excluding: ['middle']

        context "Changing options" do
          before { click_on "Change options" }

          it_behaves_like "an index page", tab: 'Choose country'
          it_behaves_like "a form filter", id: '#country', country: 'scotland', school_types_excluding: ['middle']
        end

        context "results page" do
          include_context 'results page context'
          before { click_on 'Benchmark name' }

          it_behaves_like "a results page"
          it_behaves_like "a filter summary", country: "Scotland", school_types_excluding: ['middle']

          context "Changing options" do
            before { click_on "Change options" }

            it_behaves_like "an index page", tab: 'Choose country'
            it_behaves_like "a form filter", id: '#country', country: 'scotland', school_types_excluding: ['middle']
          end
        end
      end
    end

    context "'Type' filter tab" do
      before { click_on 'Choose type' }

      it_behaves_like "an index page", tab: 'Choose type'
      it { expect(page).to have_content "Compare schools by type" }

      it_behaves_like "a form filter", id: '#type', school_type: []

      context "Benchmark page" do
        include_context 'benchmarks page context'
        before do
          within '#type' do
            select 'Primary'
            click_on 'Compare schools'
          end
        end

        it_behaves_like "a filter summary", school_types: ['primary']
        it_behaves_like "a benchmark list page"

        context "Changing options" do
          before { click_on "Change options" }

          it_behaves_like "an index page", tab: 'Choose type'
          it_behaves_like "a form filter", id: '#type', school_type: 'Primary'
        end

        context "results page" do
          include_context 'results page context'
          before { click_on 'Benchmark name' }

          it_behaves_like "a results page"
          it_behaves_like "a filter summary", school_types: ['primary']

          context "Changing options" do
            before { click_on "Change options" }

            it_behaves_like "an index page", tab: 'Choose type'
            it_behaves_like "a form filter", id: '#type', school_type: 'Primary'
          end
        end
      end
    end

    context "'Groups' filter tab" do
      before { click_on 'Choose groups' }

      it_behaves_like "an index page", tab: 'Choose groups'
      it { expect(page).to have_content "Compare schools in groups" }
      it_behaves_like "a form filter", id: '#groups', school_groups: [], school_types_excluding: [] # show all

      context "Benchmark page" do
        include_context 'benchmarks page context'
        before do
          within '#groups' do
            select 'Group 1'
            select 'Group 2'
            uncheck 'Infant'
            click_on 'Compare schools'
          end
        end

        it_behaves_like "a benchmark list page"
        it_behaves_like "a filter summary", school_types_excluding: ['infant'], school_groups: ["Group 1", "Group 2"]

        context "Changing options" do
          before { click_on "Change options" }

          it_behaves_like "an index page", tab: 'Choose groups'
          it_behaves_like "a form filter", id: '#groups', school_groups: ["Group 1", "Group 2"], school_types_excluding: ['infant']
        end

        context "results page" do
          include_context 'results page context'
          before { click_on 'Benchmark name' }

          it_behaves_like "a results page"
          it_behaves_like "a filter summary", school_types_excluding: ['infant'], school_groups: ["Group 1", "Group 2"]

          context "Changing options" do
            before { click_on "Change options" }

            it_behaves_like "an index page", tab: 'Choose groups'
            it_behaves_like "a form filter", id: '#groups', school_groups: ["Group 1", "Group 2"], school_types_excluding: ['infant']
          end
        end
      end
    end
  end

  context "Logged in user without school group" do
    let(:user) { create(:admin) }

    it_behaves_like "an index page", tab: 'Choose country', show_your_group_tab: false
  end

  context "Logged out user" do
    let(:user) {}

    it_behaves_like "an index page", tab: 'Choose country', show_your_group_tab: false
  end

  context "Admin user" do
    let(:user) { create(:admin) }

    context "'Country' filter tab" do
      before { click_on 'Choose country' }

      it_behaves_like "an index page", tab: 'Choose country', show_your_group_tab: false
      it { expect(page).to have_content "Compare schools by country" }
      it { expect(page).to have_content "Limit to funder (admin only option)"}

      it_behaves_like "a form filter", id: '#country', country: "All countries"

      context "Benchmark page" do
        include_context 'benchmarks page context'
        before do
          within '#country' do
            choose 'Scotland'
            uncheck 'Middle'
          end
          within '#funder' do
            select 'Funded by Grant Funder'
          end
          within '#country' do
            click_on 'Compare schools'
          end
        end

        it_behaves_like "a benchmark list page"
        it_behaves_like "a filter summary", country: "Scotland", school_types_excluding: ['middle']
        it_behaves_like "a filter summary", funder: "Grant Funder"

        context "Changing options" do
          before { click_on "Change options" }

          it_behaves_like "an index page", tab: 'Choose country', show_your_group_tab: false
          it_behaves_like "a form filter", id: '#country', country: 'scotland', school_types_excluding: ['middle']
          it_behaves_like "a form filter", id: '#country', funder: "Funded by Grant Funder"
        end

        context "results page" do
          include_context 'results page context'
          before { click_on 'Benchmark name' }

          it_behaves_like "a results page"
          it_behaves_like "a filter summary", country: "Scotland", school_types_excluding: ['middle']
          it_behaves_like "a filter summary", funder: "Grant Funder"

          context "Changing options" do
            before { click_on "Change options" }

            it_behaves_like "an index page", tab: 'Choose country', show_your_group_tab: false
            it_behaves_like "a form filter", id: '#country', country: 'scotland', school_types_excluding: ['middle']
          end
        end
      end
    end
  end

  describe "Redirecting old benchmark to new compare routes", type: :request do
    before do
      get old_benchmark_url
    end

    context "/benchmarks" do
      let(:old_benchmark_url) { "/benchmarks" }

      it { expect(response).to redirect_to('/compare') }
      it { expect(response.status).to eq(301) }
    end

    context "/benchmark" do
      context "with school groups" do
        let(:old_benchmark_url) { "/benchmark?benchmark_type=a_benchmark_key&benchmark%5Bschool_group_ids%5D%5B%5D=&benchmark%5Bschool_group_ids%5D%5B%5D=#{school_group.id}&benchmark%5Bschool_group_ids%5D%5B%5D=#{school_group_2.id}&benchmark%5Bschool_types%5D%5B%5D=&benchmark%5Bschool_types%5D%5B%5D=0&benchmark%5Bschool_types%5D%5B%5D=1&benchmark%5Bschool_types%5D%5B%5D=2&benchmark%5Bschool_types%5D%5B%5D=3&benchmark%5Bschool_group_ids%5D%5B%5D=&benchmark%5Bschool_types%5D%5B%5D=4&benchmark%5Bschool_types%5D%5B%5D=5&benchmark%5Bschool_types%5D%5B%5D=6&commit=Compare" }

        it "redirects to the new pages" do
          expect(response).to redirect_to("/compare/a_benchmark_key?search=groups&school_group_ids%5B%5D=#{school_group.id}&school_group_ids%5B%5D=#{school_group_2.id}&school_types%5B%5D=primary&school_types%5B%5D=secondary&school_types%5B%5D=special&school_types%5B%5D=infant&school_types%5B%5D=junior&school_types%5B%5D=middle&school_types%5B%5D=mixed_primary_and_secondary")
        end

        it { expect(response.status).to eq(301) }
      end

      context "without school groups" do
        let(:old_benchmark_url) { '/benchmark?benchmark%5Bschool_types%5D%5B%5D=0&benchmark%5Bschool_types%5D%5B%5D=1&benchmark%5Bschool_types%5D%5B%5D=2&benchmark%5Bschool_types%5D%5B%5D=3&benchmark%5Bschool_types%5D%5B%5D=4&benchmark%5Bschool_types%5D%5B%5D=5&benchmark%5Bschool_types%5D%5B%5D=6&benchmark_type=a_benchmark_key' }

        it "redirects to the new pages" do
          expect(response).to redirect_to('/compare/a_benchmark_key?search=groups&school_types%5B%5D=primary&school_types%5B%5D=secondary&school_types%5B%5D=special&school_types%5B%5D=infant&school_types%5B%5D=junior&school_types%5B%5D=middle&school_types%5B%5D=mixed_primary_and_secondary')
        end

        it { expect(response.status).to eq(301) }
      end
    end
  end
end
