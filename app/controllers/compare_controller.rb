class CompareController < ApplicationController
  include UserTypeSpecific

  before_action :header_fix_enabled
  skip_before_action :authenticate_user!

  before_action :filter
  before_action :latest_benchmark_run, except: [:index]
  before_action :content_manager, except: [:index]
  before_action :benchmark_count, only: [:index]
  before_action :benchmark_groups, only: [:benchmarks]

  # filters
  def index
  end

  # pick benchmark
  def benchmarks
  end

  def show
    @results = fetch_results # unless @filter[:school_group_ids].empty?
    @benchmark = @filter[:benchmark].to_sym
    @benchmark_groups = [{ name: '', benchmarks: { @benchmark => @benchmark } }]

    sort_content_and_page_groups(@benchmark_groups)
  end

  private

  def filter
    @filter ||=
      params.permit(:search, :benchmark, school_group_ids: [], school_types: [])
        .with_defaults(school_group_ids: [], school_types: School.school_types.keys)
        .to_hash.symbolize_keys
  end

  def all_school_types
    School.school_types.keys
  end

  def params_for_school_filter
    @filter.slice(:school_group_ids, :school_types)
  end

  def fetch_results
    include_invisible = can? :show, :all_schools

    splatted_params = { include_invisible: include_invisible }.merge(params_for_school_filter)
    schools = SchoolFilter.new(**splatted_params).filter
    schools = schools.select {|s| can?(:show, s) } unless include_invisible

    Alerts::CollateBenchmarkData.new(@latest_benchmark_run).perform(schools)
  end

  def latest_benchmark_run
    @latest_benchmark_run ||= BenchmarkResultGenerationRun.latest
  end

  def content_manager
    @content_manager ||= Benchmarking::BenchmarkContentManager.new(@latest_benchmark_run.run_date)
  end

  def benchmark_count
    # Count is of all available benchmarks for guest users only
    @benchmark_count ||= Benchmarking::BenchmarkManager.structured_pages(user_type: user_type_hash_guest).inject(0) { |count, group| count + group[:benchmarks].count }
  end

  def benchmark_groups
    @benchmark_groups ||= @content_manager.structured_pages(school_ids: nil, filter: nil, user_type: user_type_hash)
  end

  def content_for_page(benchmark, errors = [])
    @content_manager.content(@results, benchmark, user_type: user_type_hash, online: true)
    # rubocop:disable Lint/RescueException
  rescue Exception => e
    # rubocop:enable Lint/RescueException
    # Rollbar.error(e, benchmark: benchmark)

    error_message = "Exception: #{benchmark}: #{e.class} #{e.message}"

    backtrace = e.backtrace.select { |b| b.include?('analytics')}.join("<br>")
    full_html_output = "Exception: #{benchmark}: #{e.class} #{e.message} #{backtrace}"
    errors << { message: error_message, full_html_output: full_html_output }
    {}
  end

  def sort_content_and_page_groups(benchmark_groups)
    @content_hash = {}
    @errors = []

    benchmark_groups.each do |heading_hash|
      heading_hash[:benchmarks].each_key do |benchmark|
        @content_hash[benchmark] = filter_content(content_for_page(benchmark, @errors))
      end
    end
  end

  def content_select?(content)
    return false unless content.present?
    [:chart, :html, :table_composite, :title].include?(content[:type]) && content[:content].present?
  end

  def filter_content(all_content)
    all_content.select { |content| content_select?(content) }
  end
end
