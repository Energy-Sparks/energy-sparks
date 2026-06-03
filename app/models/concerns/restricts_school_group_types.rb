module RestrictsSchoolGroupTypes
  extend ActiveSupport::Concern

  included do
    validate :school_group_type_is_allowed
  end

  def school_group_type_is_allowed
    school_group = associated_school_group
    return unless school_group.present?
    return unless school_group.group_type.in?(SchoolGroup::RESTRICTED_GROUP_TYPES)

    errors.add(:base, "Cannot associate with school group of type: #{school_group.group_type}")
  end

  private

  def associated_school_group
    if respond_to?(:school_group)
      school_group
    end
  end
end
