# == Schema Information
#
# Table name: school_group_partners
#
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  partner_id      :bigint(8)
#  position        :integer
#  school_group_id :bigint(8)
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_school_group_partners_on_partner_id       (partner_id)
#  index_school_group_partners_on_school_group_id  (school_group_id)
#
class SchoolGroupPartner < ApplicationRecord
  belongs_to :school_group
  belongs_to :partner

  validates :school_group, :partner, presence: true
end
