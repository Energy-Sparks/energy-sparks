# == Schema Information
#
# Table name: school_meter_attributes
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
#  school_id      :bigint(8)        not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_school_meter_attributes_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (deleted_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (replaced_by_id => school_meter_attributes.id) ON DELETE => nullify
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class SchoolMeterAttribute < ApplicationRecord
  include AnalyticsAttribute
  belongs_to :school

  scope :floor_area_pupil_numbers, -> { where(attribute_type: 'floor_area_pupil_numbers') }

  def invalidate_school_cache_key
    school.invalidate_cache_key
  end
end
