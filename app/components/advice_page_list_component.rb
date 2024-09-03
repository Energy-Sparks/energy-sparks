class AdvicePageListComponent < ApplicationComponent
  attr_reader :school

  include ApplicationHelper
  include AdvicePageHelper

  def initialize(school:, id: nil, classes: '')
    super(id: id, classes: classes)
    @school = school
  end

  def advice_page_benchmarks
    @advice_page_benchmarks ||= @school.advice_page_school_benchmarks
  end

  def advice_pages
    @advice_pages ||= AdvicePage.all
  end

  def render?
    advice_pages.any? && school.data_enabled?
  end
end
