# frozen_string_literal: true

module SchoolGroups
  class BaseController < ApplicationController
    load_and_authorize_resource :school_group

    def self.breadcrumbs(school_group, last)
      [{ name: I18n.t('common.schools'), href: schools_path },
       { name: school_group.name, href: school_group_path(school_group) },
       last]
    end

    private

    def set_breadcrumbs(last)
      @breadcrumbs = self.class.breadcrumbs(@school_group, last)
    end
  end
end
