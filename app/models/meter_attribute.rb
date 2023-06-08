# == Schema Information
#
# Table name: meter_attributes
#
#  attribute_type :string           not null
#  created_at     :datetime         not null
#  created_by_id  :bigint(8)
#  deleted_by_id  :bigint(8)
#  id             :bigint(8)        not null, primary key
#  input_data     :json
#  meter_id       :bigint(8)        not null
#  reason         :text
#  replaced_by_id :bigint(8)
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_meter_attributes_on_meter_id  (meter_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (deleted_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (meter_id => meters.id) ON DELETE => cascade
#  fk_rails_...  (replaced_by_id => meter_attributes.id) ON DELETE => nullify
#

class MeterAttribute < ApplicationRecord
  include AnalyticsAttribute
  belongs_to :meter

  def invalidate_school_cache_key
    meter.school.invalidate_cache_key
  end

  def self.to_analytics(meter_attributes)
    meter_attributes.inject({}) do |collection, attribute|
      aggregation = attribute.meter_attribute_type.attribute_aggregation
      if aggregation
        collection[aggregation] ||= []
        collection[aggregation] << attribute.to_analytics
        collection
      else
        collection.merge(attribute.to_analytics)
      end
    end
  end

  def self.solar_panels
    query = <<-SQL.squish
      SELECT ma.id, m.school_id, ma.meter_id, solar.*
      FROM meter_attributes ma
      INNER JOIN meters m ON ma.meter_id = m.id,
      JSON_TO_RECORD(ma.input_data) AS solar(start_date TEXT, end_date TEXT, kwp TEXT, orientation TEXT, tilt TEXT, shading TEXT, fit_£_per_kwh TEXT, maximum_export_level_kw TEXT)
      WHERE ma.attribute_type='solar_pv' AND ma.deleted_by_id IS NULL AND ma.replaced_by_id IS NULL
      ORDER BY meter_id;
    SQL
    sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
    MeterAttribute.connection.select_all(sanitized_query).rows.map do |row|
      OpenStruct.new(
        meter_attribute_id: row[0],
        meter_id: row[1],
        school_id: row[2],
        start_date: row[3],
        end_date: row[4],
        kwp: row[5],
        orientation: row[6],
        tilt: row[7],
        shading: row[8],
        fit_£_per_kwh: row[9],
        maximum_export_level_kw: row[10]
      )
    end
  end
end
