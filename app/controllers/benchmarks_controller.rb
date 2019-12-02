require 'dashboard'

class BenchmarksController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :filter_lists, only: [:show, :show_all]
  before_action :benchmark_results, only: [:show, :show_all]

  def index
    @page_groups = content_manager.structured_pages
  end

  def show
    respond_to do |format|
      format.html do
        @page = params[:benchmark_type].to_sym
        #results_hash = get_content([@page])

        @page_groups = [{
          name: '', benchmarks: { @page => @page }
        }]

        @errors = []
        @form_path = benchmark_path

        @content_hash = {}
        @content_hash[@page] = filter_content(content_for_page(@page, @errors))
      end
      format.yaml { send_data YAML.dump(@benchmark_results), filename: "benchmark_results_data.yaml" }
    end
  end

  def show_all
    # @content_list = available_pages
    # results_hash = get_content(available_pages)

    # @content = results_hash[:content]
    # @errors = results_hash[:errors]
    @title = 'All benchmark results'
    @form_path = all_benchmarks_path

    @page_groups = content_manager.structured_pages

    @content_hash = {}
    errors = []

    @page_groups.each do |heading_hash|
      heading_hash[:benchmarks].each do |page, _title|
        @content_hash[page] = filter_content(content_for_page(page, errors))
      end
    end

    render :show
  end

private

  def content_for_page(page, errors = [])
    content_manager.content(@benchmark_results, page)
    # rubocop:disable Lint/RescueException
  rescue Exception => e
    # rubocop:enable Lint/RescueException
    error_message = "Exception: #{page}: #{e.class} #{e.message} #{e.backtrace.join("\n")}"
    errors << error_message
    {}
  end

  def benchmark_results
    @school_group_ids = params.dig(:benchmark, :school_group_ids) || []
    @fuel_type = params.dig(:benchmark, :fuel_type)

    schools = SchoolFilter.new(school_group_ids: @school_group_ids, fuel_type: @fuel_type).filter
    @benchmark_results = Alerts::CollateBenchmarkData.new.perform(schools)
  end

  def filter_lists
    @school_groups = SchoolGroup.all
    @fuel_types = [:gas, :electricity, :solar_pv, :storage_heaters]
  end

  def get_content(pages)
    all_content = []
    errors = []

    pages.each do |page, title|
      begin
        all_content << content_manager.content(@benchmark_results, page)
        # rubocop:disable Lint/RescueException
      rescue Exception => e
        # rubocop:enable Lint/RescueException
        errors << "Exception: #{title}: #{e.class} #{e.message} #{e.backtrace.join("\n")}"
      end
    end

    { content: filter_content(all_content.flatten), errors: errors }
  end

  def available_pages(filter: nil, school_ids: nil)
    content_manager.available_pages(filter: filter, school_ids: school_ids)
  end

  def filter_content(all_content)
    all_content.select { |content| content.present? && [:chart, :html, :table_composite, :title].include?(content[:type]) && content[:content].present? }
  end

  def content_manager(date = Time.zone.today)
    Benchmarking::BenchmarkContentManager.new(date)
  end
end
