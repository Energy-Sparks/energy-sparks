# == Schema Information
#
# Table name: team_members
#
#  id          :bigint           not null, primary key
#  description :text
#  position    :integer          default(0), not null
#  role        :integer          default("staff"), not null
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class TeamMember < ApplicationRecord
  has_one_attached :image
  has_rich_text :profile

  enum :role, { staff: 0, consultant: 1, trustee: 2 }

  validates :title, :image, :role, presence: true
  validates :position, numericality: true, presence: true
end
