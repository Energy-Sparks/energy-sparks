# == Schema Information
#
# Table name: school_group_clusters
#
#  id              :bigint           not null, primary key
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_group_id :bigint           not null
#
# Indexes
#
#  index_school_group_clusters_on_school_group_id  (school_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_group_id => school_groups.id) ON DELETE => cascade
#
class SchoolGroupCluster < ApplicationRecord
  belongs_to :school_group
  has_many :schools
  scope :by_name, -> { order(name: :asc) }
  validates :name, presence: true, uniqueness: { scope: :school_group_id }
end
