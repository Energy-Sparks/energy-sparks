# frozen_string_literal: true

module SchoolGroups
  class BaseController < ApplicationController
    include SchoolGroupBreadcrumbs

    load_and_authorize_resource :school_group
  end
end
