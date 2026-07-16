# frozen_string_literal: true

module AdminSchoolGroupBreadcrumbs
  private

  def build_breadcrumbs(extra)
    @breadcrumbs = [{ name: 'Admin Home', href: admin_path },
                    { name: 'School Groups', href: admin_school_groups_path },
                    *extra]
  end
end
