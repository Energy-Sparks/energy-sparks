# == Schema Information
#
# Table name: global_meter_attributes
#
#  attribute_type :string           not null
#  created_at     :datetime         not null
#  created_by_id  :bigint(8)
#  deleted_by_id  :bigint(8)
#  id             :bigint(8)        not null, primary key
#  input_data     :json
#  meter_types    :jsonb
#  reason         :text
#  replaced_by_id :bigint(8)
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_global_meter_attributes_on_created_by_id   (created_by_id)
#  index_global_meter_attributes_on_deleted_by_id   (deleted_by_id)
#  index_global_meter_attributes_on_replaced_by_id  (replaced_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (deleted_by_id => users.id) ON DELETE => restrict
#  fk_rails_...  (replaced_by_id => global_meter_attributes.id) ON DELETE => nullify
#

class GlobalMeterAttribute < ApplicationRecord
  include AnalyticsAttribute

  def invalidate_school_cache_key
    School.all.map(&:invalidate_cache_key)
  end

  def self.for(meter)
    where('meter_types ? :meter_type', meter_type: meter.meter_type).active
  end

  def self.pseudo
    all.inject({}) do |collection, attribute|
      attribute.selected_meter_types.select {|selected| attribute.pseudo?(selected)}.each do |meter_type|
        collection[meter_type] ||= []
        collection[meter_type] << attribute
      end
      collection
    end
  end
end
