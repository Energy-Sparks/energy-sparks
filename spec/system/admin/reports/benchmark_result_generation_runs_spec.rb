require 'rails_helper'

describe BenchmarkResultGenerationRun, type: :system, include_application_helper: true do

  let(:run)                 { BenchmarkResultGenerationRun.create! }
  let!(:admin)              { create(:admin) }
  let!(:school_1)           { create(:school) }

  let!(:run)                { BenchmarkResultGenerationRun.create! }
  let!(:school_run)         { BenchmarkResultSchoolGenerationRun.create(school: school_1, benchmark_result_generation_run: run ) }
  let!(:alert_type_1)       { create(:alert_type, benchmark: true, source: :analytics) }
  let!(:benchmark_result_1) { BenchmarkResult.create!(
                              alert_type: alert_type_1,
                              asof: Date.parse('01/01/2019'),
                              benchmark_result_school_generation_run: school_run,
                              data: {
                                "number_example"=>1.0,
                                "string_example"=>"Asdfgh",
                                "time_of_day"=> TimeOfDay.new(0,10)
                              })
                            }

  let!(:benchmark_error)    { BenchmarkResultError.create!(
                              alert_type: alert_type_1,
                              asof_date: Date.parse('01/01/2018'),
                              benchmark_result_school_generation_run: school_run,
                              information: 'Something went terribly wrong'
                              )
                            }

  before(:each) do
    sign_in(admin)
    visit root_path
  end

  it 'shows a benchmark result run and allows the user to drill down' do
    click_on 'Manage'
    click_on 'Reports'
    click_on 'Benchmark Result Generation Runs'
    expect(page).to have_content('Benchmark Result Generation Runs')
    expect(page).to have_content(nice_date_times(run.created_at))
    click_on 'Show details'
    expect(page).to have_content(nice_date_times(run.created_at).strip)
    benchmark_result_1.data.each_key do |variable_name|
      expect(page).to have_content(variable_name)
    end
    expect(page).to have_content(1.0)
    expect(page).to have_content('Asdfgh')
    expect(page).to have_content('00:10')

    expect(page).to have_content(benchmark_error.information)
  end
end
