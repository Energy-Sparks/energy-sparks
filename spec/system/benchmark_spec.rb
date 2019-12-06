require 'rails_helper'

describe 'Benchmarks' do

  let!(:school_1)           { create(:school) }

  #TODO Change this to be a normal user
  let!(:user)       { create(:admin, school: school_1)}

  let!(:run_1)              { BenchmarkResultSchoolGenerationRun.create(school: school_1, benchmark_result_generation_run: BenchmarkResultGenerationRun.create! ) }
  let!(:alert_type_1)       { create(:alert_type, benchmark: true, source: :analytics) }
  let!(:benchmark_result_1) { BenchmarkResult.create!(
                              alert_type: alert_type_1,
                              asof: Date.parse('01/01/2019'),
                              benchmark_result_school_generation_run: run_1,
                              data: {
                                "number_example"=>1.0,
                                "string_example"=>"A",
                                "time_of_day"=> TimeOfDay.new(0,10)
                              })
                            }

  let(:benchmark_content_manager_instance) { double(:benchmark_content_manager_instance) }

  let(:example_content) {
    [
      {:type=>:title, :content=>'Title goes here'},
      {:type=>:html, :content=>'Some HTML'},
      {:type=>:table_text, :content=>'Table text'},
      {:type=>:analytics_html, :content=>'analytics html'},
      {:type=>:chart_data, :content=>'chart data'},
      {:type=>:table_composite, :content=> { header: ['column 1'], rows: [[{ formatted: 'row 1', raw: 'row 1'}]] }}
    ]
  }

  before(:each) do
    sign_in(user)
    expect(Benchmarking::BenchmarkContentManager).to receive(:new).at_least(:twice).and_return(benchmark_content_manager_instance)
    expect(benchmark_content_manager_instance).to receive(:structured_pages).at_least(:once).and_return( [ { name: 'cat1', benchmarks: { page_a: 'Page A'} } ] )
    expect(benchmark_content_manager_instance).to receive(:content).and_return(example_content)

    visit root_path
    click_on 'Schools'
    click_on 'compare schools'
  end

  it 'an admin user can view a single benchmarks' do

    click_on 'Page A'
    expect(page).to have_content(example_content.detect { |a| a[:type] == :title }[:content])
    expect(page).to have_content(example_content.detect { |a| a[:type] == :html }[:content])
    expect(page).to have_content(example_content.detect { |a| a[:type] == :table_composite }[:content][:header].first)

    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :chart_data }[:content])
    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :analytics_html }[:content])
    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :table_text }[:content])
  end

  it 'an admin user can view all the benchmarks' do
    click_on 'See all on one page'
    expect(page).to have_content(example_content.detect { |a| a[:type] == :title }[:content])
    expect(page).to have_content(example_content.detect { |a| a[:type] == :html }[:content])
    expect(page).to have_content(example_content.detect { |a| a[:type] == :table_composite }[:content][:header].first)

    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :chart_data }[:content])
    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :analytics_html }[:content])
    expect(page).to_not have_content(example_content.detect { |a| a[:type] == :table_text }[:content])
  end
end
