module SchoolGroups
  class AdviceController < SchoolGroups::Advice::BaseController
    MODAL_ID = 'analysis-footnotes'.freeze
    CACHE_TIME = 1.hour

    include Scoring
    include Promptable

    def show
      build_breadcrumbs([name: I18n.t('advice_pages.breadcrumbs.root')])

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
      build_breadcrumbs([name: I18n.t('advice_pages.index.priorities.title')])
      respond_to do |format|
        format.html do
          service = SchoolGroups::PriorityActions.new(@schools)
          @priority_actions = service.priority_actions
          @total_savings = service.total_savings_by_average_one_year_saving
        end
        format.csv do
          send_data priority_actions_csv, filename: csv_filename_for('priority_actions')
        end
      end
    end

    def alerts
      build_breadcrumbs([name: I18n.t('advice_pages.index.alerts.title')])
    end

    def scores
      build_breadcrumbs([name: I18n.t('school_groups.titles.current_scores')])
      setup_scores_and_years(@school_group)
      respond_to do |format|
        format.html {}
        format.csv do
          send_data SchoolGroups::CurrentScoresCsvGenerator.new(school_group: @school_group,
                                                                scored_schools: @scored_schools,
                                                                include_cluster:).export,
                    filename: csv_filename_for(params[:previous_year].present? ? 'previous_scores' : 'current_scores')
        end
      end
    end

    def comparison_reports
      build_breadcrumbs([name: I18n.t('school_groups.titles.comparisons')])
    end

    def charts
      build_breadcrumbs([name: I18n.t('school_groups.titles.charts')])
      @charts = SchoolGroups::Charts.new.safe_charts
      @default_school = params[:school].present? ? School.find_by(slug: params[:school]) : nil
      @default_chart_type = params[:chart_type]&.to_sym
      @default_fuel_type = params[:fuel_type]&.to_sym
    end

    private

    def breadcrumbs; end

    def set_titles
      @advice_page_title = "#{t('advice_pages.index.title')} | #{@school_group.name}"
    end

    def csv_filename_for(action)
      title = I18n.t("school_groups.titles.#{action}")
      EnergySparks::Filenames.csv("#{@school_group.name}-#{title}".parameterize)
    end

    def include_cluster
      helpers.include_clusters?(@school_group)
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
  end
end
