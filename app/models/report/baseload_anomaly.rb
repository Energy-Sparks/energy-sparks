# frozen_string_literal: true

# == Schema Information
#
# Table name: report_baseload_anomalies
#
#  id                    :bigint(8)
#  meter_id              :bigint(8)
#  previous_day_baseload :decimal(, )
#  reading_date          :date
#  today_baseload        :decimal(, )
#
# Indexes
#
#  index_report_baseload_anomalies_on_id  (id) UNIQUE
#
module Report
  class BaseloadAnomaly < ApplicationRecord
    include Metered

    self.table_name_prefix = 'report_'

    def readonly?
      true
    end

    def self.refresh
      Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
    end
  end
end
