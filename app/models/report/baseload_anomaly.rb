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
    self.table_name_prefix = 'report_'

    belongs_to :meter
    scope :with_meter_school_and_group, -> { includes(:meter, meter: [:school, { school: :school_group }]) }
    scope :for_school_group, ->(school_group) { where(meter: { schools: { school_group: school_group } }) }
    scope :for_admin, ->(admin) { where(meter: { schools: { school_groups: { default_issues_admin_user: admin } } }) }
    scope :default_order, -> { order(:meter_id, :reading_date) }

    def readonly?
      true
    end

    def self.refresh
      Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
    end
  end
end
