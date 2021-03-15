# == Schema Information
#
# Table name: school_partners
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  partner_id :bigint(8)
#  position   :integer
#  school_id  :bigint(8)
#  updated_at :datetime         not null
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
