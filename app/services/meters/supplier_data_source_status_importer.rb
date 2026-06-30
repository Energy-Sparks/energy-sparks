# frozen_string_literal: true

require 'csv'

module Meters
  class SupplierDataSourceStatusImporter
    def import(data) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      meter = Meter.find_by(mpan_mprn: data[:meter])
      return if meter.blank?

      data_source = DataSource.find_by(name: data[:data_source])
      meter.update!(data_source:) if data_source.present?

      supplier = Supplier.find_by(name: data[:supplier])
      meter.update!(supplier:) if supplier.present?

      status = AdminMeterStatus.find_by(label: data[:status])
      if status.present? || (status.blank? && meter.admin_meter_status&.label == 'Manual Request')
        meter.update!(admin_meter_status: status)
      end

      meter
    end
  end
end
