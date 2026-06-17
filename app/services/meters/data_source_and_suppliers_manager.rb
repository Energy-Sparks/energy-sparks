# frozen_string_literal: true

require 'csv'

module Meters
  class DataSourceAndSuppliersManager
    def import_from_csv(csv_path) # rubocop:disable Metrics/AbcSize
      meter_data = CSV.parse(File.read(csv_path), headers: true)
      meter_data.each do |row|
        meter = Meter.where(mpan_mprn: row['Meter'])
        if meter.present?
          data_source = DataSource.where(name: row['Updated Data Source']).first
          if data_source.blank?
            warn "Can't find data source with name #{row['Updated Data Source']}"
            next
          end
          supplier = Supplier.where(name: row['Supplier']).first
          if supplier.blank?
            warn "Can't find supplier with name #{row['Supplier']}"
            next
          end
          meter.update!(data_source:, supplier:)
        else
          warn "Can't find meter with mpan_mprn #{row['Meter']}"
        end
      rescue => e # rubocop:disable Style/RescueStandardError
        warn e.message
      end
    end
  end
end
