# frozen_string_literal: true

require 'csv'

module Meters
  class SupplierDataSourceStatusImporter
    def import(data)
      meter = Meter.find_by(mpan_mprn: data[:meter])
      return if meter.blank?

      updated_data = {
        data_source: find_data_source(data, meter),
        supplier: find_supplier(data, meter),
        status: find_status(data, meter)
      }

      meter.update!(data_source: updated_data[:data_source], supplier: updated_data[:supplier],
                    admin_meter_status: updated_data[:status])

      meter
    end

    def find_data_source(data, meter)
      if data[:data_source].blank?
        nil
      else
        new_data_source = DataSource.find_by(name: data[:data_source])
        if new_data_source.present?
          new_data_source
        else
          warn "Cannot find data source with name #{data[:data_source]} for meter #{data[:meter]}"
          meter.data_source
        end
      end
    end

    def find_supplier(data, meter)
      if data[:supplier].blank?
        nil
      else
        new_supplier = Supplier.find_by(name: data[:supplier])
        if new_supplier.present?
          new_supplier
        else
          warn "Cannot find supplier with name #{data[:supplier]} for meter #{data[:meter]}"
          meter.supplier
        end
      end
    end

    def find_status(data, meter)
      if data[:status].blank?
        nil
      else
        new_status = AdminMeterStatus.find_by(label: data[:status])
        if new_status.present?
          new_status
        else
          warn "Cannot find meter status with label #{data[:status]} for meter #{data[:meter]}"
          meter.admin_meter_status
        end
      end
    end
  end
end
