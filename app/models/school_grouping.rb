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
#  index_school_groupings_on_school_id_and_main_role  (school_id,role) UNIQUE WHERE (role = 'organisation'::school_grouping_role)
#
# Foreign Keys
#
#  fk_rails_...  (school_group_id => school_groups.id)
#  fk_rails_...  (school_id => schools.id)
#
class SchoolGrouping < ApplicationRecord
  belongs_to :school
  belongs_to :school_group

  enum :role, %i[organisation area project].index_with(&:to_s), prefix: true

  validates :role, presence: true
  validates :role, inclusion: { in: roles.keys }

  validate :only_one_organisation_group
  validate :role_matches_group_type

  def only_one_organisation_group
    return unless role_organisation?

    existing = SchoolGrouping.where(school_id: school_id, role: 'organisation')
    existing = existing.where.not(id: id) if persisted?

    if existing.exists?
      errors.add(:role, 'already has a organisation group assigned')
    end
  end

  def role_matches_group_type
    return unless school_group

    case school_group.group_type
    when *SchoolGroup::ORGANISATION_GROUP_TYPE_KEYS
      errors.add(:role, 'must be organisation for this group type') unless role_organisation?
    when *SchoolGroup::AREA_GROUP_TYPE_KEYS
      errors.add(:role, 'must be area for this group type') unless role_area?
    else
      errors.add(:role, 'must be project for project groups') unless role_project?
    end
  end
end
