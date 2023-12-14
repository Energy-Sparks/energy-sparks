class CompareController < ApplicationController
  include UserTypeSpecific
  skip_before_action :authenticate_user!

  before_action :filter
  before_action :benchmark_groups, only: [:benchmarks]

  before_action :set_included_schools, only: [:benchmarks, :show]
  helper_method :index_params

  # filters
  def index
    # Count is of all available benchmarks for guest users only
    @benchmark_count = Benchmarking::BenchmarkManager.structured_pages(user_type: user_type_hash_guest).inject(0) { |count, group| count + group[:benchmarks].count }
  end

  # pick benchmark
  def benchmarks
    if @included_schools.empty?
      render :no_schools and return
    end
  end

  # display results
  def show
    #user wouldn't be able to get here, but adding in case crawlers/bots hit the page
    if @included_schools.empty?
      render :no_schools
    else
      benchmark = filter[:benchmark].to_sym
      @content = BenchmarkContentFilter.new(content_for_benchmark(benchmark))
      @content.title ||= extract_title_from_benchmark(benchmark)
    end
  end

  private

  def filter
    @filter ||=
      params.permit(:search, :benchmark, :country, :school_type, :funder, school_group_ids: [], school_types: [])
        .with_defaults(school_group_ids: [], school_types: School.school_types.keys)
        .to_hash.symbolize_keys
  end

  def index_params
    filter.merge(anchor: filter[:search])
  end

  def latest_benchmark_run
    @latest_benchmark_run ||= BenchmarkResultGenerationRun.latest
  end

  def content_manager
    @content_manager ||= Benchmarking::BenchmarkContentManager.new(latest_benchmark_run.run_date)
  end

  def benchmark_groups
    @benchmark_groups ||= content_manager.structured_pages(user_type: user_type_hash)
  end

  def set_included_schools
    @included_schools = included_schools
  end

  def included_schools
    # wonder if this can be replaced by a use of the scope accessible_by(current_ability)
    include_invisible = can? :show, :all_schools
    school_params = filter.slice(:school_group_ids, :school_types, :school_type, :country, :funder).merge(include_invisible: include_invisible)

    schools = SchoolFilter.new(**school_params).filter
    schools.select {|s| can?(:show, s) } unless include_invisible
    schools
  end

  def fetch_benchmark_data
    Alerts::CollateBenchmarkData.new(latest_benchmark_run).perform(@included_schools)
  end

  def content_for_benchmark(benchmark)
    content_manager.content(fetch_benchmark_data, benchmark, user_type: user_type_hash, online: true)
    # rubocop:disable Lint/RescueException
  rescue Exception => e
    # rubocop:enable Lint/RescueException
    Rollbar.error(e, benchmark: benchmark)
    []
  end

  def extract_title_from_benchmark(benchmark)
    benchmark_groups.find {|group| group[:benchmarks]}.dig(:benchmarks, benchmark)
  end
end
