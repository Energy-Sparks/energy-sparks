# == Schema Information
#
# Table name: cads
#
#  id                :bigint(8)        not null, primary key
#  active            :boolean          default(FALSE)
#  device_identifier :string           not null
#  max_power         :float            default(3.0)
#  name              :string           not null
#  refresh_interval  :integer          default(5)
#  test_mode         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  meter_id          :bigint(8)
#  school_id         :bigint(8)        not null
#
# Indexes
#
#  index_cads_on_meter_id   (meter_id)
#  index_cads_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (meter_id => meters.id)
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class Cad < ApplicationRecord
  belongs_to :school
  belongs_to :meter, optional: true

  validates_presence_of :name, :device_identifier

  scope :active, -> { where(active: true) }
end
