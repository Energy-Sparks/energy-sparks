# == Schema Information
#
# Table name: cads
#
#  active            :boolean          default(FALSE)
#  created_at        :datetime         not null
#  device_identifier :string           not null
#  id                :bigint(8)        not null, primary key
#  max_power         :float            default(3.0)
#  meter_id          :bigint(8)
#  name              :string           not null
#  refresh_interval  :integer          default(5)
#  school_id         :bigint(8)        not null
#  test_mode         :boolean          default(FALSE)
#  updated_at        :datetime         not null
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

  validates :name, :device_identifier, presence: true

  scope :active, -> { where(active: true) }
end
