# == Schema Information
#
# Table name: school_groupings
#
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  role            :enum             not null
#  school_group_id :bigint(8)        not null
#  school_id       :bigint(8)        not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_school_groupings_on_school_group_id          (school_group_id)
#  index_school_groupings_on_school_id                (school_id)
#  index_school_groupings_on_school_id_and_main_role  (school_id,role) UNIQUE WHERE (role = 'main'::school_grouping_role)
#
# Foreign Keys
#
#  fk_rails_...  (school_group_id => school_groups.id)
#  fk_rails_...  (school_id => schools.id)
#
class SchoolGrouping < ApplicationRecord
  belongs_to :school
  belongs_to :school_group

  enum :role, {
    main: 'main',
    area: 'area',
    project: 'project'
  }, prefix: true

  validates :role, presence: true
  validates :role, inclusion: { in: roles.keys }

  validate :only_one_main_group, on: :create

  def only_one_main_group
    return unless role_main?

    if SchoolGrouping.exists?(school_id: school_id, role: 'main')
      errors.add(:role, 'already has a main group assigned')
    end
  end
end
