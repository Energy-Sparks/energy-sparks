# == Schema Information
#
# Table name: school_group_meter_attributes
#
#  attribute_type  :string           not null
#  created_at      :datetime         not null
#  created_by_id   :bigint(8)
#  deleted_by_id   :bigint(8)
#  id              :bigint(8)        not null, primary key
#  input_data      :json
#  meter_type      :string           not null
#  reason          :text
#  replaced_by_id  :bigint(8)
#  school_group_id :bigint(8)        not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_school_group_meter_attributes_on_school_group_id  (school_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (deleted_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (replaced_by_id => school_group_meter_attributes.id) ON DELETE => nullify
#  fk_rails_...  (school_group_id => school_groups.id) ON DELETE => cascade
#

class SchoolGroupMeterAttribute < ApplicationRecord
  include AnalyticsAttribute
  belongs_to :school_group
end
