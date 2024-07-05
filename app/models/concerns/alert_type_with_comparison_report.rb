# frozen_string_literal: true

module AlertTypeWithComparisonReport
  extend ActiveSupport::Concern

  def alert_type_title_with_report
    alert_type.title + (comparison_report.nil? ? '' : " - #{comparison_report.title}")
  end
end
