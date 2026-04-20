# == Schema Information
#
# Table name: school_partners
#
#  id         :bigint           not null, primary key
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  partner_id :bigint
#  school_id  :bigint
#
# Indexes
#
#  index_school_partners_on_partner_id  (partner_id)
#  index_school_partners_on_school_id   (school_id)
#
class SchoolPartner < ApplicationRecord
  belongs_to :school
  belongs_to :partner

  validates :school, :partner, presence: true
end
