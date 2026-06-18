# frozen_string_literal: true

require 'csv'

module Meters
  class DataSourceAndSuppliersImporter
    def import(data)
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
        meter.update!(data_source:, supplier:)
      else
        warn "Can't find meter with mpan_mprn #{data[:meter]}"
      end
    end
  end
end
