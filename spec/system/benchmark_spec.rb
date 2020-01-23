require 'rails_helper'

describe 'Benchmarks' do

  let!(:school_1)           { create(:school) }
  let!(:user)               { create(:user)}
  let!(:run_1)              { BenchmarkResultSchoolGenerationRun.create(school: school_1, benchmark_result_generation_run: BenchmarkResultGenerationRun.create! ) }
  let!(:gas_fuel_alert_type) { create(:alert_type, source: :analysis, sub_category: :heating, fuel_type: :gas, description: description, frequency: :weekly) }
  let!(:benchmark_result_1) { BenchmarkResult.create!(
                              alert_type: gas_fuel_alert_type,
                              asof: Date.parse('01/01/2019'),
                              benchmark_result_school_generation_run: run_1,
                              data: {
                                "number_example"=>1.0,
                                "string_example"=>"A",
                                "time_of_day"=> TimeOfDay.new(0,10)
                              })
                            }

  let(:benchmark_content_manager_instance) { double(:benchmark_content_manager_instance) }

  let(:description) { 'all about this alert type' }

  let(:example_content) {
    [
      {:type=>:title, :content=>'Title goes here'},
      {:type=>:html, :content=>'Some HTML'},
      {:type=>:table_text, :content=>'Table text'},
      {:type=>:analytics_html, :content=>'analytics html'},
      {:type=>:chart_data, :content=>'chart data'},
      {:type=>:table_composite, :content=> { header: ['column 1'], rows: [[{ formatted: 'row 1', raw: 'row 1'}]] }},
      {:type=>:drilldown, :content=> {:drilldown=>{:type=>:adult_dashboard, :content_class=>gas_fuel_alert_type.class_name}, :school_map=>[{:name=>"School name", :urn=>"URN"}, {:name=>school_1.name, :urn=>school_1.urn}]}}
    ]
  }

  before(:each) do
    sign_in(user)
    expect(Benchmarking::BenchmarkContentManager).to receive(:new).at_least(:twice).and_return(benchmark_content_manager_instance)
    expect(benchmark_content_manager_instance).to receive(:structured_pages).at_least(:once).and_return( [ { name: 'cat1', benchmarks: { page_a: 'Page A'} } ] )
    expect(benchmark_content_manager_instance).to receive(:content).at_least(:once).and_return(example_content)

    visit root_path
    click_on 'Schools'
    click_on 'compare schools'
  end

  it 'a user can view a single benchmarks' do
    click_on 'Page A'
    expect(page).to have_content(example_content.detect { |a| a[:type] == :title }[:content])
    expect(page).to have_content(example_content.detect { |a| a[:type] == :html }[:content])
    expect(page).to have_content(example_content.detect { |a| a[:type] == :table_composite }[:content][:header].first)

    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :chart_data }[:content])
    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :analytics_html }[:content])
    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :table_text }[:content])
  end

  it 'a user can view all the benchmarks' do
    click_on 'See all on one page'
    expect(page).to have_content(example_content.detect { |a| a[:type] == :title }[:content])
    expect(page).to have_content(example_content.detect { |a| a[:type] == :html }[:content])
    expect(page).to have_content(example_content.detect { |a| a[:type] == :table_composite }[:content][:header].first)

    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :chart_data }[:content])
    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :analytics_html }[:content])
    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :table_text }[:content])
  end

  it 'a user can drilldown to an analysis page without any content and get to a sensible page with a message' do
    click_on 'Page A'
    click_on(school_1.name)
    expect(page).to have_content('sorry')
  end

  context 'with analysis page content' do
    let!(:gas_meter) { create :gas_meter_with_reading, school: school_1 }
    let!(:alert_type_rating) do
      create(
        :alert_type_rating,
        alert_type: gas_fuel_alert_type,
        rating_from: 0,
        rating_to: 10,
        analysis_active: true
      )
    end
    let!(:alert_type_rating_content_version) do
      create(
        :alert_type_rating_content_version,
        alert_type_rating: alert_type_rating,
        analysis_title: 'You might want to think about heating',
        analysis_subtitle: 'This is what you need to do'
      )
    end
    let!(:alert) do
      create(:alert, :with_run, alert_type: gas_fuel_alert_type, school: school_1, rating: 9.0)
    end

    before do
      Alerts::GenerateContent.new(school_1).perform
    end


    it 'a user can drilldown to an analysis page' do
      expect(AlertType.count).to be 1
      allow_any_instance_of(SchoolAggregation).to receive(:aggregate_school).and_return(school_1)

      adapter = double(:adapter)
      allow(Alerts::FrameworkAdapter).to receive(:new).with(alert_type: gas_fuel_alert_type, school: school_1, analysis_date: alert.run_on, aggregate_school: school_1).and_return(adapter)
      allow(adapter).to receive(:content).and_return(
        [
          {type: :enhanced_title, content: { title: 'Heating advice', rating: 10.0 }},
          {type: :html, content: '<h2>Turn your heating down</h2>'},
          {type: :chart_name, content: :benchmark}
        ]
      )

      click_on 'Page A'
      click_on(school_1.name)
      expect(page).to have_content('Heating advice')
    end
  end
end
