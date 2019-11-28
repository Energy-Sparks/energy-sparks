require 'dashboard'

class BenchmarksController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :benchmark_results, only: [:show, :show_all]

  def index
    @content_list = available_pages
    @school_groups = SchoolGroup.all
  end

  def show
    respond_to do |format|
      format.html do
        @page = params[:benchmark_type].to_sym
        results_hash = get_content([@page])

        @content = results_hash[:content]
        @errors = results_hash[:errors]
        @form_path = benchmark_path
      end
      format.yaml { send_data YAML.dump(@benchmark_results), filename: "benchmark_results_data.yaml" }
    end
  end

  def show_all
    @content_list = available_pages
    results_hash = get_content(available_pages)

    @content = results_hash[:content]
    @errors = results_hash[:errors]
    @title = 'All benchmark results'
    @form_path = all_benchmarks_path

    render :show
  end

private

  def benchmark_results
    @school_groups = SchoolGroup.all
    @school_group_ids = params.dig(:benchmark, :school_group_ids) || []

    if @school_group_ids.empty?
      schools = School.process_data
    else
      puts @school_group_ids
      @school_group_ids.reject!(&:blank?)
      schools = School.process_data.where(school_group_id: @school_group_ids)
    end
    @benchmark_results = Alerts::CollateBenchmarkData.new.perform(schools)
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
    all_content.select { |content| [:chart, :html, :table_composite, :title].include?(content[:type]) && content[:content].present? }
  end

  def content_manager(date = Time.zone.today)
    Benchmarking::BenchmarkContentManager.new(date)
  end
end
