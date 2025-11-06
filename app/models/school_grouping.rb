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
#  index_school_groupings_on_school_group_id                  (school_group_id)
#  index_school_groupings_on_school_id                        (school_id)
#  index_school_groupings_on_school_id_and_organisation_role  (school_id,role) UNIQUE WHERE (role = 'organisation'::school_grouping_role)
#
# Foreign Keys
#
#  fk_rails_...  (school_group_id => school_groups.id)
#  fk_rails_...  (school_id => schools.id)
#
class SchoolGrouping < ApplicationRecord
  belongs_to :school
  belongs_to :school_group

  # Used to organise and validate the relationships between School and SchoolGroup
  #
  # There will be at most one "organisation" relationship between a School and a
  # SchoolGroup. Equivalent to a has_one relationship.
  #
  # There may be many "area" and "project" relationships.
  #
  # The types of SchoolGroup that can participate in those relationships is also
  # restricted. "organisation" relationships are limited to "general", "local_authority",
  # and "multi_academy_trust" group types.
  #
  # "project" roles can only refer to "project" SchoolGroups. The remaining
  # SchoolGroup types are restricted to "area" relationships.
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
