class BenchmarksController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    filter = nil
    school_ids = nil
    @content_list = content_manager.available_pages(filter: filter, school_ids: school_ids)
  end

  def show
    @page = params[:benchmark_type].to_sym

    results = Alerts::CollateBenchmarkData.new.perform
    all_content = content_manager.content(results, @page)

    @content = all_content.select { |content| [:chart, :html, :table_text, :analytics_html].include?(content[:type])}

    @title = page_title(@content)
  end

private

  def content_manager
    Benchmarking::BenchmarkContentManager.new(Time.zone.today)
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
