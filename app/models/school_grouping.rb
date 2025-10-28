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

  validate :only_one_main_group
  validate :role_matches_group_type

  def only_one_main_group
    return unless role_main?

    existing = SchoolGrouping.where(school_id: school_id, role: 'main')
    existing = existing.where.not(id: id) if persisted?

    if existing.exists?
      errors.add(:role, 'already has a main group assigned')
    end
  end

  def role_matches_group_type
    return unless school_group

    case school_group.group_type
    when 'general', 'local_authority', 'multi_academy_trust'
      errors.add(:role, 'must be main for this group type') unless role_main?
    when 'diocese', 'local_authority_area'
      errors.add(:role, 'must be area for this group type') unless role_area?
    else
      errors.add(:role, 'must be project for project groups') unless role_project?
    end
  end
end
