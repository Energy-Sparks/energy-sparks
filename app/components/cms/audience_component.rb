module Cms
  class AudienceComponent < ApplicationComponent
    def initialize(page:, current_user:, **kwargs)
      super
      @audience = page.audience.to_sym
      @role = current_user&.role&.to_sym
    end

    def has_permission?
      return true if @audience == :anyone
      return true if @audience == :school_users && @role.present?
      return true if @audience == :group_admins && @role == :group_admin
      return @audience == :school_admins && [:school_onboarding, :school_admin, :group_admin, :admin].include?(@role)
    end
  end
end
