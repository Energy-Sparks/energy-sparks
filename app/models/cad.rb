# == Schema Information
#
# Table name: cads
#
#  active            :boolean          default(TRUE)
#  created_at        :datetime         not null
#  device_identifier :string           not null
#  id                :bigint(8)        not null, primary key
#  name              :string           not null
#  school_id         :bigint(8)        not null
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
end
