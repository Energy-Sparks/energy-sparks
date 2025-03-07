# frozen_string_literal: true

class SchoolGroupComparisonComponent < ApplicationComponent
  renders_one :footer
  renders_one :csv_download_link

  include ApplicationHelper

  CATEGORIES = [:exemplar_school, :benchmark_school, :other_school].freeze

  def initialize(comparison:, advice_page_key:, include_cluster: false, **_kwargs)
    super
    @comparison = comparison
    @advice_page_key = advice_page_key
    @include_cluster = include_cluster
  end

  def modal_title_for(category)
    t("advice_pages.#{@advice_page_key}.page_title") + ' > ' + t("advice_pages.benchmarks.#{category}")
  end

  def modal_id_for(category)
    "#{@advice_page_key.to_s.camelize + category.to_s.camelize}ModalCenter"
  end

  def count_for(category)
    @comparison[category]&.size || 0
  end

  def categories
    SchoolGroupComparisonComponent::CATEGORIES
  end

  def advice_page_path_for(school_slug)
    send("school_advice_#{@advice_page_key}_path", school_id: school_slug)
  end

  def include_cluster?
    @include_cluster
  end
end
