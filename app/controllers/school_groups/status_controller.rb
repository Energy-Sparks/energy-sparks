# frozen_string_literal: true

module SchoolGroups
  class StatusController < BaseController
    include SchoolGroupAccessControl

    layout 'group_settings'
    load_and_authorize_resource :school, through: :school_group

    before_action :load_schools, only: [:index, :meters]
    before_action :load_onboardings, only: [:index]
    before_action :redirect_unless_authorised
    before_action :breadcrumbs, only: [:index, :school]

    def index
      respond_to do |format|
        format.html do
          render :index
        end
        format.csv do
          send_data SchoolGroups::SchoolStatusCsvGenerator.new(school_group: @school_group,
                                                              schools: @schools,
                                                              include_cluster: false).export,
                    filename: EnergySparks::Filenames.csv("#{@school_group.slug}-schools-status")
        end
      end
    end

    def school
      respond_to do |format|
        format.html { render :school }
        format.csv { meter_csv }
      end
    end

    def meters
      meter_csv
    end

    private

    def meter_csv
      send_data SchoolGroups::SchoolMeterStatusCsvGenerator.new(school_group: @school_group,
      schools: @schools || [@school],
      include_cluster: false).export,
filename: EnergySparks::Filenames.csv("#{@school_group.slug}-schools-meter-status")
    end

    def load_onboardings
      @onboardings = @school_group.onboardings_for_group.incomplete # .accessible_by(current_ability, :show)
    end

    def redirect_unless_authorised
      redirect_to map_school_group_path(@school_group) and return unless Flipper.enabled?(:group_settings, current_user)
      redirect_to map_school_group_path(@school_group) and return if cannot?(:compare, @school_group)

      # modified filtering of schools, because we have onboardings to consider too
      if @schools && @schools.empty? && @onboardings && @onboardings.empty?
        redirect_to map_school_group_path(@school_group) and return
      end
    end

    def breadcrumbs
      if @school
        @breadcrumbs = [name: I18n.t('school_groups.titles.school_status')]
      else
        build_breadcrumbs([name: I18n.t('school_groups.titles.school_status')])
      end
    end
  end
end
