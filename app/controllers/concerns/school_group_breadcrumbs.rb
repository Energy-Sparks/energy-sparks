# frozen_string_literal: true

module SchoolGroupBreadcrumbs
  private

  def set_breadcrumbs(last)
    @breadcrumbs = [{ name: I18n.t('common.schools'), href: schools_path },
                    { name: @school_group.name, href: school_group_path(@school_group) },
                    last]
  end
end
