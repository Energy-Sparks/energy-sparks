require 'rails_helper'

describe 'compare pages', :compare, type: :system do
  shared_examples 'an index page' do |tab:, show_your_group_tab: true|
    it 'has standard header information' do
      expect(page).to have_content 'School Comparison Tool'
      expect(page).to have_content 'Identify examples of best practice'
      expect(page).to have_content 'View how schools within the same MAT'
      expect(page).to have_content 'Use options below to compare 3 schools against 1 benchmarks'
    end

    it 'has standard tabs' do
      expect(page).to have_link('Choose country', href: '#country')
      expect(page).to have_link('Choose type', href: '#type')
      expect(page).to have_link('Choose groups', href: '#groups')
    end

    it "has 'Your group' tab", if: show_your_group_tab do
      expect(page).to have_link('Your group', href: '#group')
    end

    it "doesn't have 'Your group' tab", unless: show_your_group_tab do
      expect(page).not_to have_link('Your group', href: '#group')
    end

    it "#{tab} tab is selected", js: true do
      expect(page).to have_css('a.nav-link.active', text: tab)
    end
  end

  shared_examples 'a benchmark list page' do |edit: false|
    it { expect(page).to have_content('Benchmark group name') }
    it { expect(page).to have_content('Benchmark description') }
    it { expect(page).to have_link('Baseload per pupil', href: %r{^/compar(e|isons)/baseload_per_pupil?}) }
    it { expect(page).not_to have_link('Disabled report') }

    it 'allows report group to be edited', if: edit do
      within first('div.compare') do
        expect(page).to have_link('Edit')
      end
    end

    it 'does not allow report group to be edited', unless: edit do
      within first('div.compare') do
        expect(page).not_to have_link('Edit')
      end
    end
  end

  shared_examples 'a results page' do |display_new_comparison_pages: false, edit: false|
    it { expect(page).to have_selector('h1', text: 'Baseload per pupil') }
    it { expect(page).to have_content('intro html') }

    it 'allows report introduction to be edited', if: display_new_comparison_pages && edit do
      within('#intro') do
        expect(page).to have_link('Edit')
      end
    end

    it 'does not allow report introduction to be edited', unless: display_new_comparison_pages && edit do
      within('#intro') do
        expect(page).not_to have_link('Edit')
      end
    end

    it 'includes tabular data', unless: display_new_comparison_pages do
      within '#tables' do
        expect(page).not_to have_content('Baseload per pupil')
        expect(page).to have_content('table html')
        expect(page).to have_content('Benchmark 2')
        expect(page).to have_content('table composite 2 header')
        expect(page).to have_content('table html')
      end
    end

    it 'includes tabular data', if: display_new_comparison_pages do
      within '#tables' do
        expect(page).to have_selector(:table_row, {
          'School' => "#{school.name} [5]",
          'Baseload per pupil (W)' => '3,000',
          'Last year cost of baseload' => '£2',
          'Average baseload kW' => '1',
          'Baseload as a percent of total usage' => '400&percnt;',
          'Saving if matched exemplar school (using latest tariff)' => '£5'
        })
      end
    end

    it 'excludes fragments', unless: display_new_comparison_pages do
      within '#tables' do
        expect(page).not_to have_content('table text')
        expect(page).not_to have_content('analytics html')
        expect(page).not_to have_content('chart data')
      end
    end

    it 'includes charts', unless: display_new_comparison_pages do
      within '#charts' do
        expect(page).to have_css('div#chart_config_name.analysis-chart')
        expect(page).to have_content('chart html')
      end
    end

    it 'includes charts', if: display_new_comparison_pages do
      within '#charts' do
        expect(page).to have_css('div#chart_comparison')
      end
    end

    it { expect(page).to have_link('Change benchmark') }
  end

  shared_examples 'an unlisted schools modal' do
    it "doesn't display included schools" do
      within '.modal-body' do
        expect(page).not_to have_link school.name
      end
    end

    it 'displays schools' do
      within '.modal-body' do
        unlisted_schools.each do |school|
          expect(page).to have_link school.name, href: school_path(school)
        end
      end
    end
  end

  shared_examples 'a results page with unlisted schools' do |unlisted_count: 0|
    context 'with no excluded schools', if: unlisted_count == 0 do
      it { expect(page).not_to have_content 'school could not be shown in this report' }
    end

    context 'with multiple excluded schools', if: unlisted_count > 1 do
      it { expect(page).to have_content("#{unlisted_count} schools could not be shown in this report as they do not have enough data to be analysed") }
      it { expect(page).to have_link('View list of schools') }
    end

    context 'with a single excluded school', if: unlisted_count == 1 do
      it { expect(page).to have_content('1 school could not be shown in this report as it does not have enough data to be analysed') }
      it {expect(page).to have_link('View school') }
    end
  end

  shared_examples 'a form filter' do |id:, school_types_excluding: nil, school_type: nil, country: nil, funder: nil, school_groups: nil, school_group_list: nil|
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

    it 'has school type select', if: school_type do
      within id.to_s do
        expect(page).to have_select('school_type', selected: school_type)
      end
    end

    it 'has country radio buttons', if: country do
      within id.to_s do
        expect(page).to have_checked_field(country)
      end
    end

    it 'has funder select', if: funder do
      within id.to_s do
        expect(page).to have_select('funder', selected: funder)
      end
    end

    it 'has school groups selected', if: school_groups do
      within id.to_s do
        expect(page).to have_select('school_group_ids', selected: school_groups)
      end
    end

    it 'has school groups available', if: school_group_list do
      within id.to_s do
        expect(page).to have_select('school_group_ids', options: school_group_list)
      end
    end
  end

  shared_examples 'a filter summary' do |school_types: nil, school_types_excluding: nil, country: nil, school_groups: nil, funder: nil|
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

  shared_examples 'an empty filter notice' do
    it { expect(page).to have_content('There are no schools to report using this filter') }
  end

  ## contexts ##

  shared_context 'index page context' do |display_new_comparison_pages: false|
    before do
      if display_new_comparison_pages
        create(:report, key: 'baseload_per_pupil', title: 'Baseload per pupil', introduction: 'intro html', public: true)
        create(:report, key: 'disabled_report', title: 'Disabled', public: true, disabled: true)
      else
        expect(Benchmarking::BenchmarkManager).to receive(:structured_pages).at_least(:once).and_return(benchmark_groups)
      end
    end
  end

  shared_context 'benchmarks page context' do |display_new_comparison_pages: false|
    if display_new_comparison_pages
      before do
        create(:report_group, title: 'Benchmark group name', description: 'Benchmark description')
      end
    else
      let!(:content_manager) { double(:content_manager) }

      before do
        BenchmarkResultSchoolGenerationRun.create!(school: school, benchmark_result_generation_run: BenchmarkResultGenerationRun.create!)
        expect(Benchmarking::BenchmarkContentManager).to receive(:new).at_least(:once).and_return(content_manager)
        expect(content_manager).to receive(:structured_pages).at_least(:once).and_return(benchmark_groups)
      end
    end
  end

  shared_context 'results page context' do |display_new_comparison_pages: false|
    if display_new_comparison_pages
      include_context 'with comparison report footnotes' do
        let(:footnotes) { [tariff_changed_last_year] }
      end

      before do
        create(:advice_page, key: :baseload)

        alert_run = create(:alert_generation_run, school: school)
        create(:alert, alert_generation_run: alert_run, school: school,
          alert_type: create(:alert_type, class_name: 'AlertElectricityBaseloadVersusBenchmark'),
            variables: {
              average_baseload_last_year_kw: 1.0,
              average_baseload_last_year_gbp: 2.0,
              one_year_baseload_per_pupil_kw: 3.0,
              annual_baseload_percent: 4.0,
              one_year_saving_versus_exemplar_gbp: 5.0
            })
        create(:alert, alert_generation_run: alert_run, school: school,
          alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
            variables: {
              electricity_economic_tariff_changed_this_year: true
            })
      end
    else
      let!(:gas_fuel_alert_type) { create(:alert_type, source: :analysis, sub_category: :heating, fuel_type: :gas, frequency: :weekly) }
      let(:example_content) do
        [
          { type: :title, content: 'Baseload per pupil' },
          { type: :html, content: 'intro html' },
          { type: :chart, content: { title: 'chart title', config_name: 'config_name', x_axis: ['a school'] } },
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
  end

  ## tests start here ##

  [true, false].each do |feature_flag|
    context "when comparison report feature flag is #{feature_flag}" do
      let(:user) {}
      let(:all_school_types) { School.school_types.keys }
      let!(:funder)          { create(:funder, name: 'Grant Funder') }
      # the stubbed out geocoder stamps on the country if the postcode is defaulted
      let!(:school_group)    { create(:school_group, name: 'Group 1') }
      let!(:school_group_2)  { create(:school_group, name: 'Group 2') }
      let!(:school)          { create(:school, country: :scotland, postcode: 'EH99 1SP', school_group: school_group, funder: funder)}
      let!(:school_2)        { create(:school, country: :scotland, postcode: 'EH99 1SP', school_group: school_group_2)}
      let!(:school_3)        { create(:school, country: :scotland, school_group: create(:school_group, name: 'Not Public', public: false)) }

      let(:benchmark_groups) { [{ name: 'Benchmark group name', description: 'Benchmark description', benchmarks: { baseload_per_pupil: 'Baseload per pupil' } }] }

      before do
        feature_flag ? Flipper.enable(:comparison_reports) : Flipper.disable(:comparison_reports)
        sign_in(user) if user
      end

      include_context 'index page context', display_new_comparison_pages: feature_flag

      before { visit compare_index_path }

      context 'when user is logged in user with school group' do
        let(:user) { create(:user, school_group: school_group) }

        it_behaves_like 'an index page', tab: 'Your group'

        context "'Your group' filter tab" do
          before { click_on 'Your group' }

          it_behaves_like 'an index page', tab: 'Your group'

          it { expect(page).to have_content "Compare all schools within #{user.school_group_name}" }
          it_behaves_like 'a form filter', id: '#group', school_types_excluding: [] # show all

          context 'Benchmark page' do
            include_context 'benchmarks page context', display_new_comparison_pages: feature_flag

            before do
              within '#group' do
                uncheck 'Junior'
                click_on 'Compare schools'
              end
            end

            it_behaves_like 'a benchmark list page'
            it_behaves_like 'a filter summary', school_types_excluding: ['junior']

            context 'Changing options' do
              before { click_on 'Change options' }

              it_behaves_like 'an index page', tab: 'Your group'
              it_behaves_like 'a form filter', id: '#group', school_types_excluding: ['junior']
            end

            context 'results page' do
              include_context 'results page context', display_new_comparison_pages: feature_flag

              before { click_on 'Baseload per pupil' }

              it_behaves_like 'a results page', display_new_comparison_pages: feature_flag
              it_behaves_like 'a filter summary', school_types_excluding: ['junior']

              context 'Changing options' do
                before { click_on 'Change options' }

                it_behaves_like 'an index page', tab: 'Your group'
                it_behaves_like 'a form filter', id: '#group', school_types_excluding: ['junior']
              end
            end
          end
        end

        context "'Country' filter tab" do
          before { click_on 'Choose country' }

          it_behaves_like 'an index page', tab: 'Choose country'
          it { expect(page).to have_content 'Compare schools by country' }

          it_behaves_like 'a form filter', id: '#country', country: 'All countries'

          context 'Benchmark page' do
            include_context 'benchmarks page context', display_new_comparison_pages: feature_flag

            before do
              within '#country' do
                choose 'Scotland'
                uncheck 'Middle'
                click_on 'Compare schools'
              end
            end

            it_behaves_like 'a benchmark list page'
            it_behaves_like 'a filter summary', country: 'Scotland', school_types_excluding: ['middle']

            context 'Changing options' do
              before { click_on 'Change options' }

              it_behaves_like 'an index page', tab: 'Choose country'
              it_behaves_like 'a form filter', id: '#country', country: 'scotland', school_types_excluding: ['middle']
            end

            context 'results page' do
              include_context 'results page context', display_new_comparison_pages: feature_flag

              before { click_on 'Baseload per pupil' }

              it_behaves_like 'a results page', display_new_comparison_pages: feature_flag
              it_behaves_like 'a filter summary', country: 'Scotland', school_types_excluding: ['middle']

              context 'Changing options' do
                before { click_on 'Change options' }

                it_behaves_like 'an index page', tab: 'Choose country'
                it_behaves_like 'a form filter', id: '#country', country: 'scotland', school_types_excluding: ['middle']
              end
            end
          end
        end

        context "'Type' filter tab" do
          before { click_on 'Choose type' }

          it_behaves_like 'an index page', tab: 'Choose type'
          it { expect(page).to have_content 'Compare schools by type' }

          it_behaves_like 'a form filter', id: '#type', school_type: []

          context 'Benchmark page' do
            include_context 'benchmarks page context', display_new_comparison_pages: feature_flag

            before do
              within '#type' do
                select 'Primary'
                click_on 'Compare schools'
              end
            end

            it_behaves_like 'a filter summary', school_types: ['primary']
            it_behaves_like 'a benchmark list page'

            context 'Changing options' do
              before { click_on 'Change options' }

              it_behaves_like 'an index page', tab: 'Choose type'
              it_behaves_like 'a form filter', id: '#type', school_type: 'Primary'
            end

            context 'results page' do
              include_context 'results page context', display_new_comparison_pages: feature_flag

              before { click_on 'Baseload per pupil' }

              it_behaves_like 'a results page', display_new_comparison_pages: feature_flag
              it_behaves_like 'a filter summary', school_types: ['primary']

              context 'Changing options' do
                before { click_on 'Change options' }

                it_behaves_like 'an index page', tab: 'Choose type'
                it_behaves_like 'a form filter', id: '#type', school_type: 'Primary'
              end
            end
          end
        end

        context "'Groups' filter tab" do
          before { click_on 'Choose groups' }

          it_behaves_like 'an index page', tab: 'Choose groups'
          it { expect(page).to have_content 'Compare schools in groups' }
          it_behaves_like 'a form filter', id: '#groups', school_group_list: ['Group 1', 'Group 2'], school_groups: [], school_types_excluding: [] # show all

          context 'Benchmark page' do
            include_context 'benchmarks page context', display_new_comparison_pages: feature_flag

            before do
              within '#groups' do
                select 'Group 1'
                select 'Group 2'
                uncheck 'Infant'
                click_on 'Compare schools'
              end
            end

            it_behaves_like 'a benchmark list page'
            it_behaves_like 'a filter summary', school_types_excluding: ['infant'], school_groups: ['Group 1', 'Group 2']

            context 'Changing options' do
              before { click_on 'Change options' }

              it_behaves_like 'an index page', tab: 'Choose groups'
              it_behaves_like 'a form filter', id: '#groups', school_group_list: ['Group 1', 'Group 2'], school_groups: ['Group 1', 'Group 2'], school_types_excluding: ['infant']
            end

            context 'Filtering all schools' do
              before do
                click_on 'Change options'
                within '#groups' do
                  uncheck 'Primary'
                  click_on 'Compare schools'
                end
              end

              it_behaves_like 'a filter summary', school_types_excluding: ['infant'], school_groups: ['Group 1', 'Group 2']
              it_behaves_like 'an empty filter notice'
            end

            context 'results page' do
              include_context 'results page context', display_new_comparison_pages: feature_flag

              before { click_on 'Baseload per pupil' }

              it_behaves_like 'a results page', display_new_comparison_pages: feature_flag
              it_behaves_like 'a filter summary', school_types_excluding: ['infant'], school_groups: ['Group 1', 'Group 2']

              context 'Changing options' do
                before { click_on 'Change options' }

                it_behaves_like 'an index page', tab: 'Choose groups'
                it_behaves_like 'a form filter', id: '#groups', school_groups: ['Group 1', 'Group 2'], school_types_excluding: ['infant']
              end
            end
          end
        end
      end

      context 'when user is logged out' do
        let(:user) {}

        it_behaves_like 'an index page', tab: 'Choose country', show_your_group_tab: false
        it_behaves_like 'a form filter', id: '#groups', school_group_list: ['Group 1', 'Group 2']
      end

      context 'When user is admin' do
        let(:user) { create(:admin) }

        context "'Country' filter tab" do
          before { click_on 'Choose country' }

          it_behaves_like 'an index page', tab: 'Choose country', show_your_group_tab: false
          it { expect(page).to have_content 'Compare schools by country' }
          it { expect(page).to have_content 'Limit to funder (admin only option)'}

          it_behaves_like 'a form filter', id: '#country', country: 'All countries'
          it_behaves_like 'a form filter', id: '#groups', school_group_list: ['Group 1', 'Group 2', 'Not Public']

          context 'Benchmark page' do
            include_context 'benchmarks page context', display_new_comparison_pages: feature_flag

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

            it_behaves_like 'a benchmark list page', edit: feature_flag
            it_behaves_like 'a filter summary', country: 'Scotland', school_types_excluding: ['middle']
            it_behaves_like 'a filter summary', funder: 'Grant Funder'

            context 'Changing options' do
              before { click_on 'Change options' }

              it_behaves_like 'an index page', tab: 'Choose country', show_your_group_tab: false
              it_behaves_like 'a form filter', id: '#country', country: 'scotland', school_types_excluding: ['middle']
              it_behaves_like 'a form filter', id: '#country', funder: 'Funded by Grant Funder'
            end

            context 'results page' do
              include_context 'results page context', display_new_comparison_pages: feature_flag

              before { click_on 'Baseload per pupil' }

              it_behaves_like 'a results page', display_new_comparison_pages: feature_flag, edit: true
              it_behaves_like 'a filter summary', country: 'Scotland', school_types_excluding: ['middle']
              it_behaves_like 'a filter summary', funder: 'Grant Funder'

              context 'Changing options' do
                before { click_on 'Change options' }

                it_behaves_like 'an index page', tab: 'Choose country', show_your_group_tab: false
                it_behaves_like 'a form filter', id: '#country', country: 'scotland', school_types_excluding: ['middle']
              end
            end
          end
        end
      end
    end
  end

  context 'when comparison report feature is switched on' do
    before do
      Flipper.enable :comparison_reports
    end

    describe 'displaying unlisted schools on the results page' do
      # school should be the only school with results
      let!(:school)    { create(:school, name: 'Included school') }
      let(:excluded_1) { create(:school, name: 'Excluded 1') }
      let(:excluded_2) { create(:school, name: 'Excluded 2') }

      let!(:unlisted_schools) { }

      include_context 'index page context', display_new_comparison_pages: true
      include_context 'results page context', display_new_comparison_pages: true

      before { visit comparisons_baseload_per_pupil_index_path }

      context 'when there are several excluded schools', js: true do
        let!(:unlisted_schools) { [excluded_1, excluded_2] }

        it_behaves_like 'a results page with unlisted schools', unlisted_count: 2

        context 'when clicking link' do
          before { click_on 'View list of schools' }

          it_behaves_like 'an unlisted schools modal'
        end
      end

      context 'when there is one excluded school', js: true do
        let(:unlisted_schools) { [excluded_1] }

        it_behaves_like 'a results page with unlisted schools', unlisted_count: 1

        context 'when clicking link' do
          before { click_on 'View school' }

          it_behaves_like 'an unlisted schools modal'
        end
      end

      context 'when there are no unlisted schools' do
        it_behaves_like 'a results page with unlisted schools', unlisted_count: 0
      end
    end
  end

  describe 'Redirecting old benchmark routes to new compare routes', type: :request do
    before do
      get old_benchmark_url
    end

    context '/benchmarks' do
      let(:old_benchmark_url) { '/benchmarks' }

      it { expect(response).to redirect_to('/compare') }
      it { expect(response.status).to eq(301) }
    end

    context '/benchmark' do
      context 'with school groups' do
        let!(:school_group) { create(:school_group) }
        let!(:school_group_2) { create(:school_group) }

        let(:old_benchmark_url) { "/benchmark?benchmark_type=baseload_per_pupil&benchmark%5Bschool_group_ids%5D%5B%5D=&benchmark%5Bschool_group_ids%5D%5B%5D=#{school_group.id}&benchmark%5Bschool_group_ids%5D%5B%5D=#{school_group_2.id}&benchmark%5Bschool_types%5D%5B%5D=&benchmark%5Bschool_types%5D%5B%5D=0&benchmark%5Bschool_types%5D%5B%5D=1&benchmark%5Bschool_types%5D%5B%5D=2&benchmark%5Bschool_types%5D%5B%5D=3&benchmark%5Bschool_group_ids%5D%5B%5D=&benchmark%5Bschool_types%5D%5B%5D=4&benchmark%5Bschool_types%5D%5B%5D=5&benchmark%5Bschool_types%5D%5B%5D=6&commit=Compare" }

        it 'redirects to the new pages' do
          expect(response).to redirect_to("/compare/baseload_per_pupil?search=groups&school_group_ids%5B%5D=#{school_group.id}&school_group_ids%5B%5D=#{school_group_2.id}&school_types%5B%5D=primary&school_types%5B%5D=secondary&school_types%5B%5D=special&school_types%5B%5D=infant&school_types%5B%5D=junior&school_types%5B%5D=middle&school_types%5B%5D=mixed_primary_and_secondary")
        end

        it { expect(response.status).to eq(301) }
      end

      context 'without school groups' do
        let(:old_benchmark_url) { '/benchmark?benchmark%5Bschool_types%5D%5B%5D=0&benchmark%5Bschool_types%5D%5B%5D=1&benchmark%5Bschool_types%5D%5B%5D=2&benchmark%5Bschool_types%5D%5B%5D=3&benchmark%5Bschool_types%5D%5B%5D=4&benchmark%5Bschool_types%5D%5B%5D=5&benchmark%5Bschool_types%5D%5B%5D=6&benchmark_type=baseload_per_pupil' }

        it 'redirects to the new pages' do
          expect(response).to redirect_to('/compare/baseload_per_pupil?search=groups&school_types%5B%5D=primary&school_types%5B%5D=secondary&school_types%5B%5D=special&school_types%5B%5D=infant&school_types%5B%5D=junior&school_types%5B%5D=middle&school_types%5B%5D=mixed_primary_and_secondary')
        end

        it { expect(response.status).to eq(301) }
      end
    end
  end
end
