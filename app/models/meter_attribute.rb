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

  def self.metered_solar
    query = <<-SQL.squish
      SELECT ma.id, m.id, s.id, s.name, solar.*
      FROM meter_attributes ma
      INNER JOIN meters m ON ma.meter_id = m.id
      INNER JOIN schools s ON m.school_id = s.id,
      JSON_TO_RECORD(ma.input_data) AS solar(
        start_date TEXT,
        end_date TEXT,
        export_mpan TEXT,
        production_mpan TEXT,
        production_mpan2 TEXT,
        production_mpan3 TEXT,
        production_mpan4 TEXT,
        production_mpan5 TEXT
      )
      WHERE ma.attribute_type='solar_pv_mpan_meter_mapping'
      AND ma.deleted_by_id IS NULL AND ma.replaced_by_id IS NULL
      AND s.active = true
      ORDER BY s.name;
    SQL
    sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
    MeterAttribute.connection.select_all(sanitized_query).rows.map do |row|
      OpenStruct.new(
        meter_attribute_id: row[0],
        meter: Meter.find(row[1]),
        school_id: row[2],
        school_name: row[3],
        start_date: row[4],
        end_date: row[5],
        export_mpan: row[6],
        production_mpans: [row[7], row[8], row[9], row[10], row[11]].reject(&:blank?)
      )
    end
  end

  def self.solar_pv
    query = <<-SQL.squish
      SELECT ma.id, m.school_id, s.name, ma.meter_id, solar.*
      FROM meter_attributes ma
      INNER JOIN meters m ON ma.meter_id = m.id
      INNER JOIN schools s ON m.school_id = s.id,
      JSON_TO_RECORD(ma.input_data) AS solar(start_date TEXT, end_date TEXT, kwp FLOAT)
      WHERE ma.attribute_type='solar_pv' AND ma.deleted_by_id IS NULL AND ma.replaced_by_id IS NULL
      AND s.active = true
      ORDER BY s.name;
    SQL
    sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
    MeterAttribute.connection.select_all(sanitized_query).rows.map do |row|
      OpenStruct.new(
        meter_attribute_id: row[0],
        school_id: row[1],
        school_name: row[2],
        meter: Meter.find(row[3]),
        start_date: row[4],
        end_date: row[5],
        kwp: row[6]
      )
    end
  end
end
