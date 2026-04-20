# frozen_string_literal: true

# == Schema Information
#
# Table name: report_gas_anomalies
#
#  id                     :bigint
#  previous_degree_days   :decimal(, )
#  previous_kwh           :decimal(, )
#  previous_reading_date  :date
#  previous_temperature   :decimal(, )
#  reading_date           :date
#  today_degree_days      :decimal(, )
#  today_kwh              :decimal(, )
#  today_temperature      :decimal(, )
#  calendar_event_type_id :bigint
#  meter_id               :bigint
#
# Indexes
#
#  index_report_gas_anomalies_on_id  (id) UNIQUE
#
module Report
  class GasAnomaly < ApplicationRecord
    self.table_name_prefix = 'report_'

    include Metered

    belongs_to :calendar_event_type

    def readonly?
      true
    end

    def self.refresh
      Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
    end
  end
end
