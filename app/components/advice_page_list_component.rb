class AdvicePageListComponent < ApplicationComponent
  attr_reader :school, :current_user

  include ApplicationHelper
  include AdvicePageHelper

  def initialize(school:, current_user:, id: nil, classes: '')
    super(id: id, classes: classes)
    @school = school
    @current_user = current_user
  end

  def advice_page_benchmarks
    @advice_page_benchmarks ||= @school.advice_page_school_benchmarks.includes(:advice_page)
  end

  def advice_pages
    @advice_pages ||= AdvicePage.all
  end

  def render?
    advice_pages.any? && school.data_enabled?
  end

  private

  def benchmark_for(advice_page)
    advice_page_benchmarks.detect {|benchmark| benchmark.advice_page == advice_page }
  end
end
