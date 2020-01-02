require 'dashboard'

class BenchmarksController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :page_groups, only: [:index, :show_all]
  before_action :filter_lists, only: [:show, :show_all]
  before_action :benchmark_results, only: [:show, :show_all]

  def index
    @school_group_ids = params.dig(:benchmark, :school_group_ids).reject(&:empty?) || []
    @school_group_names = SchoolGroup.find(@school_group_ids).pluck(:name).join(', ')
  end

  def show
    respond_to do |format|
      format.html do
        @page = params[:benchmark_type].to_sym
        @page_groups = [{ name: '', benchmarks: { @page => @page } }]
        @form_path = benchmark_path

        sort_content_and_page_groups(@page_groups)
      end
      format.yaml { send_data YAML.dump(@benchmark_results), filename: "benchmark_results_data.yaml" }
    end
  end

  def show_all
    @title = 'All benchmark results'
    @form_path = all_benchmarks_path

    sort_content_and_page_groups(@page_groups)

    render :show
  end

private

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
    content_manager.content(@benchmark_results, page)
    # rubocop:disable Lint/RescueException
  rescue Exception => e
    # rubocop:enable Lint/RescueException
    error_message = "Exception: #{page}: #{e.class} #{e.message}"

    backtrace = e.backtrace.select { |b| b.include?('analytics')}.join("<br>")
    full_html_output = "Exception: #{page}: #{e.class} #{e.message} #{backtrace}"
    errors << { message: error_message, full_html_output: full_html_output }
    {}
  end

  def page_groups
    user_type_hash = if current_user
                       { user_role: current_user.role.to_sym, staff_role: current_user.staff_role_as_symbol }
                     else
                       { user_role: :guest, staff_role: nil }
                     end

    @page_groups = content_manager.structured_pages(school_ids: nil, filter: nil, user_type: user_type_hash)
  end

  def filter_lists
    @school_groups = SchoolGroup.all
  end

  def benchmark_results
    @school_group_ids = params.dig(:benchmark, :school_group_ids) || []

    include_invisible = can? :show, :all_schools

    schools = SchoolFilter.new(school_group_ids: @school_group_ids, include_invisible: include_invisible).filter
    @benchmark_results = Alerts::CollateBenchmarkData.new.perform(schools)
  end

  def content_manager(date = Time.zone.today)
    Benchmarking::BenchmarkContentManager.new(date)
  end

  def filter_content(all_content)
    all_content.select { |content| content_select?(content) }
  end

  def content_select?(content)
    return false unless content.present?

    [:chart, :html, :table_composite, :title].include?(content[:type]) && content[:content].present?
  end
end
