# == Schema Information
#
# Table name: school_group_cluster_schools
#
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  school_group_cluster_id :bigint(8)        not null
#  school_id               :bigint(8)        not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_school_group_cluster_schools_on_school_group_cluster_id  (school_group_cluster_id)
#  index_school_group_cluster_schools_on_school_id                (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_group_cluster_id => school_group_clusters.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class SchoolGroupClusterSchool < ApplicationRecord
  belongs_to :school_group_cluster
  belongs_to :school
end
