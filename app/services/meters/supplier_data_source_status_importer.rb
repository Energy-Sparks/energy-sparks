# frozen_string_literal: true

require 'csv'

module Meters
  class SupplierDataSourceStatusImporter
    def import(data) # rubocop:disable Metrics/AbcSize
      meter = Meter.find_by(mpan_mprn: data[:meter])
      if meter.present?
        data_source = DataSource.find_by(name: data[:data_source])
        if data_source.blank?
          warn "Can't find data source with name #{data[:data_source]}"
          return
        end
        supplier = Supplier.find_by(name: data[:supplier])
        if supplier.blank?
          warn "Can't find supplier with name #{data[:supplier]}"
          return
        end
        if status.blank?
          warn "Can't find meter status with name #{data[:supplier]}"
          return
        end
        meter.update!(data_source:, supplier:, admin_meter_status: status)
      else
        warn "Can't find meter with mpan_mprn #{data[:meter]}"
      end
    end
  end
end
