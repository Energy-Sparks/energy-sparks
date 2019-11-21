class BenchmarksController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @content_list = available_pages
  end

  def show
    @results = Alerts::CollateBenchmarkData.new.perform
    @school_map = School.all.pluck(:id, :name).to_h

    respond_to do |format|
      format.html do
        @page = params[:benchmark_type].to_sym
        all_content = content_manager.content(@results, @page)

        @content = all_content.select { |content| [:chart, :html, :table_text, :analytics_html].include?(content[:type])}

        @title = page_title(@content)

        @days_in_results = @results.keys
      end
      format.yaml { send_data YAML.dump(@results), filename: "benchmark_results_data.yaml" }
    end
  end

  def show_all
    @content_list = available_pages
    @school_map = School.all.pluck(:id, :name).to_h
    @results = Alerts::CollateBenchmarkData.new.perform
    @date = params[:date] || Time.zone.today

    all_content = []
    errors = []

    available_pages.each do |page, title|
      begin
        all_content << content_manager(@date).content(@results, page)
        # rubocop:disable Lint/RescueException
      rescue Exception => e
        # rubocop:enable Lint/RescueException
        errors << "Exception: #{title}: #{e.class} #{e.message} #{e.backtrace.join("\n")}"
      end
    end

    @content = all_content.flatten.select { |content| [:chart, :html, :table_text, :analytics_html].include?(content[:type])}

    @days_in_results = @results.keys
    @title = 'All benchmark results'

    render :show
  end

private

  def available_pages(filter: nil, school_ids: nil)
    content_manager.available_pages(filter: filter, school_ids: school_ids)
  end

  def content_manager(date = Time.zone.today)
    Benchmarking::BenchmarkContentManager.new(date)
  end

  def page_title(content)
    title = content.find { |element| element[:type] == :title }
    if title
      title[:content]
    else
      "Missing title"
    end
  end
end
