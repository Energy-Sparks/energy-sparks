module SchoolGroups
  class AdviceController < ApplicationController
    include SchoolGroupAccessControl
    include SchoolGroupBreadcrumbs
    include Scoring

    load_resource :school_group

    before_action :load_schools
    before_action :redirect_unless_authorised
    before_action :load_school_group_fuel_types

    # Extract more of this into a concern?
    # what if not authorised?

    layout 'dashboards'

    def show
      set_breadcrumbs(name: I18n.t('advice_pages.breadcrumbs.root'))
      @fuel_types = @school_group.fuel_types

      respond_to do |format|
        format.html {}
        format.csv do
          send_data SchoolGroups::RecentUsageCsvGenerator.new(school_group: @school_group,
                                                              schools: @schools,
                                                              include_cluster:).export,
                    filename: csv_filename_for('recent_usage')
        end
      end
    end

    def priorities
      set_breadcrumbs(name: I18n.t('advice_pages.index.priorities.title'))
      respond_to do |format|
        format.html do
          service = SchoolGroups::PriorityActions.new(@schools)
          @priority_actions = service.priority_actions
          @total_savings = sort_total_savings(service.total_savings)
        end
        format.csv do
          send_data priority_actions_csv, filename: csv_filename_for('priority_actions')
        end
      end
    end

    def alerts
      set_breadcrumbs(name: I18n.t('advice_pages.index.alerts.title'))
    end

    def scores
      set_breadcrumbs(name: I18n.t('school_groups.titles.current_scores'))
      setup_scores_and_years(@school_group)
      respond_to do |format|
        format.html {}
        format.csv do
          send_data SchoolGroups::CurrentScoresCsvGenerator.new(school_group: @school_group,
                                                                scored_schools: @scored_schools,
                                                                include_cluster:).export,
                    filename: csv_filename_for(params[:academic_year].present? ? 'previous_scores' : 'current_scores')
        end
      end
    end

    private

    # Rely on CanCan to filter the list of schools to those that can be shown to the current user
    def load_schools
      @schools = @school_group.schools.active.accessible_by(current_ability, :show).by_name
    end

    # DOWNLOADS
    def csv_filename_for(action)
      title = I18n.t("school_groups.titles.#{action}")
      name = "#{@school_group.name}-#{title}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize
      "#{name}.csv"
    end

    def include_cluster
      can?(:update_settings, @school_group)
    end

    def priority_actions_csv
      if params[:alert_type_rating_ids]
        SchoolGroups::SchoolsPriorityActionCsvGenerator.new(
          schools: @schools,
          alert_type_rating_ids: params[:alert_type_rating_ids].map(&:to_i),
          include_cluster:
        ).export
      else
        SchoolGroups::PriorityActionsCsvGenerator.new(schools: @schools).export
      end
    end

    def sort_total_savings(total_savings)
      total_savings.sort do |a, b|
        b[1].average_one_year_saving_gbp <=> a[1].average_one_year_saving_gbp
      end
    end
  end
end
