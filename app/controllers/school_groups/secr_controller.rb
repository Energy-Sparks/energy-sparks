# frozen_string_literal: true

module SchoolGroups
  class SecrController < ApplicationController
    load_and_authorize_resource :school_group

    def index
      raise CanCan::AccessDenied unless current_user.admin? || current_user.group_admin?
    end
  end
end
