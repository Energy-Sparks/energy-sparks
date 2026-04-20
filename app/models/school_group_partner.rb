# == Schema Information
#
# Table name: school_group_partners
#
#  id              :bigint           not null, primary key
#  position        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  partner_id      :bigint
#  school_group_id :bigint
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
