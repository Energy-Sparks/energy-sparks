# frozen_string_literal: true

module SchoolGroupBreadcrumbs
  private

  def build_breadcrumbs(extra)
    @breadcrumbs = [{ name: I18n.t('common.schools'), href: schools_path },
                    { name: @school_group.name, href: school_group_path(@school_group) },
                    *extra]
  end
end
