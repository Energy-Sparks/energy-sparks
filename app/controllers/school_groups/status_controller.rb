# frozen_string_literal: true

module SchoolGroups
  class StatusController < BaseController
    include SchoolGroupAccessControl

    layout 'group_settings'
    load_and_authorize_resource :school, through: :school_group

    before_action :load_schools, only: [:index]
    before_action :redirect_unless_authorised

    def index
      redirect_to map_school_group_path(@school_group) and return unless Flipper.enabled?(:group_settings, current_user)
      @records = merge_schools_and_onboardings
    end

    def school
      redirect_to map_school_group_path(@school_group) and return unless Flipper.enabled?(:group_settings, current_user)
      # @meters = @school.meters.accessible_by(current_ability, :show)
      @meters = @school.meters.active
    end

    private

    def merge_schools_and_onboardings
      @onboardings = @school_group.onboardings_for_group.incomplete
      school_ids = @schools.map(&:id).to_set # should we enforce active here?

      @schools + @onboardings.reject { |o| school_ids.include?(o.school_id) }
    end

    def breadcrumbs
      build_breadcrumbs([name: I18n.t("school_groups.titles.#{action_name}")])
    end
  end
end
