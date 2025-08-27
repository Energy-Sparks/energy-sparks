# frozen_string_literal: true

module ComparisonTableGenerator
  extend ActiveSupport::Concern

  included do
    helper_method :index_params
    helper_method :footnote_cache
    helper_method :unlisted_message
  end

  # Used to store footnotes loaded by the comparison table component across multiple calls in one page
  def footnote_cache
    @footnote_cache ||= {}
  end

  private

  def header_groups
    []
  end

  def colgroups(groups: nil)
    (groups || header_groups).each { |group| group[:colspan] = group[:headers].count(&:itself) }
  end

  def headers(groups: nil)
    (groups || header_groups).pluck(:headers).flatten.select(&:itself)
  end

  # Key for the AdvicePage used to link to school analysis
  def advice_page_key
    nil
  end

  # Tab of the advice page to link to by default
  def advice_page_tab
    :insights
  end

  # Returns a list of table names. These correspond to a partial that should be
  # found in the views folder for the comparison. By default assumes a single table
  # which is defined in a file called _table.html.erb.
  #
  # Partials will be provided with the report, advice page, and results
  def table_names
    [:table]
  end

  def index_params
    filter.merge(anchor: filter[:search])
  end

  def unlisted_message(count)
    I18n.t('comparisons.unlisted.message', count: count)
  end
end
