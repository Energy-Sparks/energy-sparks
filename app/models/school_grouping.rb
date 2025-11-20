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
  enum :role, %i[organisation area project diocese].index_with(&:to_s), prefix: true

  validates :role, presence: true
  validates :role, inclusion: { in: roles.keys }

  validate :only_one_groups
  validate :role_matches_group_type

  def self.assign_group(school, code_attr:, group_type:, role:)
    establishment = school.establishment
    return unless establishment

    code = establishment.public_send(code_attr)
    return unless code

    school_group = SchoolGroup.find_by(group_type: group_type, dfe_code: code)
    return unless school_group

    grouping = joins(:school_group)
      .where(school: school, role: role, school_groups: { group_type: group_type })
      .first_or_initialize

    grouping.school_group = school_group
    grouping.save!
  end

  def self.assign_diocese(school)
    assign_group(school, code_attr: :diocese_code, group_type: :diocese, role: 'diocese')
  end

  def self.assign_area(school)
    assign_group(school, code_attr: :la_code, group_type: :local_authority_area, role: 'area')
  end

  private

  def only_one_groups
    if role_organisation?
      only_one_group_for_role('organisation')
    elsif role_diocese?
      only_one_group_for_role('diocese')
    elsif role_area?
      only_one_group_for_role('area')
    end
  end

  def only_one_group_for_role(role)
    existing = SchoolGrouping.where(school_id: school_id, role:)
    existing = existing.where.not(id: id) if persisted?

    if existing.exists?
      errors.add(:role, "already has a #{role} group assigned")
    end
  end

  def role_matches_group_type
    return unless school_group

    case school_group.group_type
    when *SchoolGroup::ORGANISATION_GROUP_TYPE_KEYS
      errors.add(:role, 'must be organisation for this group type') unless role_organisation?
    when 'diocese'
      errors.add(:role, 'must be diocese for this group type') unless role_diocese?
    when 'local_authority_area'
      errors.add(:role, 'must be area for this group type') unless role_area?
    else
      errors.add(:role, 'must be project for project groups') unless role_project?
    end
  end
end
