# == Schema Information
#
# Table name: school_group_clusters
#
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  name            :string
#  school_group_id :bigint(8)        not null
#  updated_at      :datetime         not null
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

  validates :name, presence: true
end
