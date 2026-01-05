# frozen_string_literal: true

module SchoolGroups
  class BaseController < ApplicationController
    include SchoolGroupBreadcrumbs

    load_and_authorize_resource :school_group

    private

    def required_permission
      nil
    end

    def redirect_unless_authorised
      if required_permission.present? && cannot?(required_permission, @school_group)
        redirect_to school_group_path(@school_group) and return
      end
    end
  end
end
