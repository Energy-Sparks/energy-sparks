# == Schema Information
#
# Table name: find_out_more_calculations
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  school_id  :bigint(8)        not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_find_out_more_calculations_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class FindOutMoreCalculation < ApplicationRecord
  has_many :find_out_mores
  belongs_to :school
end
