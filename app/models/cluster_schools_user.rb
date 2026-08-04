# frozen_string_literal: true

# == Schema Information
#
# Table name: cluster_schools_users
#
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_cluster_schools_users_on_school_id              (school_id)
#  index_cluster_schools_users_on_user_id                (user_id)
#  index_cluster_schools_users_on_user_id_and_school_id  (user_id,school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
class ClusterSchoolsUser < ApplicationRecord
  belongs_to :school
  belongs_to :user
end
