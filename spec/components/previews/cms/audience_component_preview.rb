module Cms
  class AudienceComponentPreview < ViewComponent::Preview
    def anyone
      render(Cms::AudienceComponent.new(current_user: nil, page: Cms::Page.where(audience: :anyone).first))
    end

    def no_user_school_admins
      render(Cms::AudienceComponent.new(current_user: nil, page: Cms::Page.where(audience: :school_admins).first))
    end

    def school_admins_with_staff
      render(Cms::AudienceComponent.new(current_user: User.staff.first, page: Cms::Page.where(audience: :school_admins).first))
    end

    def school_admins_logged_in
      render(Cms::AudienceComponent.new(current_user: User.school_admin.first, page: Cms::Page.where(audience: :school_admins).first))
    end
  end
end
