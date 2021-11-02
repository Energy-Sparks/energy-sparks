# == Schema Information
#
# Table name: cads
#
#  active            :boolean          default(TRUE)
#  created_at        :datetime         not null
#  device_identifier :string           not null
#  id                :bigint(8)        not null, primary key
#  max_power         :float            default(3.0)
#  name              :string           not null
#  refresh_interval  :integer          default(5)
#  school_id         :bigint(8)        not null
#  test_mode         :boolean          default(FALSE)
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_cads_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class Cad < ApplicationRecord
  belongs_to :school

  validates_presence_of :name, :device_identifier

  scope :active, -> { where(active: true) }
end
