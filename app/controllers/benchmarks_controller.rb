require 'dashboard'

class BenchmarksController < ApplicationController
  include UserTypeSpecific

  skip_before_action :authenticate_user!

  before_action :latest_benchmark_run
  before_action :content_manager
  before_action :page_groups, only: [:index]
  before_action :load_filter, only: [:index, :show]
  before_action :filter_lists, only: [:show]

  def index
  end

  def show
    benchmark_results unless @benchmark_filter[:school_group_ids].empty?

    respond_to do |format|
      format.html do
        @page = params.require(:benchmark_type).to_sym
        @page_groups = [{ name: '', benchmarks: { @page => @page } }]
        @form_path = benchmark_path

        sort_content_and_page_groups(@page_groups)
      end
      format.yaml { send_data YAML.dump(@benchmark_results), filename: "benchmark_results_data.yaml" }
    end
  end

private

  def latest_benchmark_run
    @latest_benchmark_run = BenchmarkResultGenerationRun.latest
  end

  def sort_content_and_page_groups(page_groups)
    @content_hash = {}
    @errors = []

    page_groups.each do |heading_hash|
      heading_hash[:benchmarks].each do |page, _title|
        @content_hash[page] = filter_content(content_for_page(page, @errors))
      end
    end
  end

  def content_for_page(page, errors = [])
    @content_manager.content(@benchmark_results, page, user_type: user_type_hash, online: true)
    # rubocop:disable Lint/RescueException
  rescue Exception => e
    # rubocop:enable Lint/RescueException
    Rollbar.error(e, benchmark: page)

    error_message = "Exception: #{page}: #{e.class} #{e.message}"

    backtrace = e.backtrace.select { |b| b.include?('analytics')}.join("<br>")
    full_html_output = "Exception: #{page}: #{e.class} #{e.message} #{backtrace}"
    errors << { message: error_message, full_html_output: full_html_output }
    {}
  end

  def page_groups
    @page_groups = @content_manager.structured_pages(school_ids: nil, filter: nil, user_type: user_type_hash)
  end

  def load_filter
    @benchmark_filter = {
      school_group_ids: (params.dig(:benchmark, :school_group_ids) || []).reject(&:empty?),
      school_types:     (params.dig(:benchmark, :school_types) || all_school_type_ids).reject(&:empty?)
    }
    school_group_names = SchoolGroup.find(@benchmark_filter[:school_group_ids]).pluck(:name).join(', ')
    @filter_names = school_group_names
  end

  def all_school_type_ids
    School.school_types.values.map(&:to_s)
  end

  def school_types_from_ids(ids)
    School.school_types.invert.values_at(*ids.map(&:to_i))
  end

  def filter_lists
    service = ComparisonService.new(current_user)
    @school_groups = service.list_school_groups
    @school_types = service.list_school_types
  end

  def benchmark_results
    include_invisible = can? :show, :all_schools

    schools = SchoolFilter.new(**{ include_invisible: include_invisible }.merge(@benchmark_filter)).filter
    unless include_invisible
      schools = schools.select {|s| can?(:show, s) }
    end
    @benchmark_results = Alerts::CollateBenchmarkData.new(@latest_benchmark_run).perform(schools)
  end

  def content_manager
    @content_manager = Benchmarking::BenchmarkContentManager.new(@latest_benchmark_run.run_date)
  end

  def filter_content(all_content)
    all_content.select { |content| content_select?(content) }
  end

  def content_select?(content)
    return false unless content.present?

    [:chart, :html, :table_composite, :title].include?(content[:type]) && content[:content].present?
  end
end
