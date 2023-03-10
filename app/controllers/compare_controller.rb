class CompareController < ApplicationController
  include UserTypeSpecific

  before_action :header_fix_enabled
  skip_before_action :authenticate_user!

  before_action :filter
  before_action :latest_benchmark_run, except: [:index]
  before_action :content_manager, except: [:index]

  # filters
  def index
    # Count is of all available benchmarks for guest users only
    @benchmark_count = Benchmarking::BenchmarkManager.structured_pages(user_type: user_type_hash_guest).inject(0) { |count, group| count + group[:benchmarks].count }
  end

  # pick benchmark
  def benchmarks
    @benchmark_groups = @content_manager.structured_pages(school_ids: nil, filter: nil, user_type: user_type_hash)
  end

  def show
    @benchmark = @filter[:benchmark].to_sym
    @content = content_for_benchmark(@benchmark)
  end

  private

  def filter
    @filter ||=
      params.permit(:search, :benchmark, school_group_ids: [], school_types: [])
        .with_defaults(school_group_ids: [], school_types: School.school_types.keys)
        .to_hash.symbolize_keys
  end

  def latest_benchmark_run
    @latest_benchmark_run ||= BenchmarkResultGenerationRun.latest
  end

  def content_manager
    @content_manager ||= Benchmarking::BenchmarkContentManager.new(@latest_benchmark_run.run_date)
  end

  def included_schools
    include_invisible = can? :show, :all_schools

    school_params = @filter.slice(:school_group_ids, :school_types).merge(include_invisible: include_invisible)
    schools = SchoolFilter.new(**school_params).filter
    schools.select {|s| can?(:show, s) } unless include_invisible
    schools
  end

  def fetch_benchmark_data
    Alerts::CollateBenchmarkData.new(@latest_benchmark_run).perform(included_schools)
  end

  def content_for_benchmark(benchmark)
    content = @content_manager.content(fetch_benchmark_data, benchmark, user_type: user_type_hash, online: true)
    return filter_content(content)
    # rubocop:disable Lint/RescueException
  rescue Exception => e
    # rubocop:enable Lint/RescueException
    Rollbar.error(e, benchmark: benchmark)
    {}
  end

  def filter_content(content)
    content.select { |content_element| select_content_element?(content_element) }
  end

  def select_content_element?(content)
    return false unless content.present?
    [:chart, :html, :table_composite, :title].include?(content[:type]) && content[:content].present?
  end
end
