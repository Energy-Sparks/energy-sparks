module Dashboards
  class GroupSavingsPromptComponent < ApplicationComponent
    include AdvicePageHelper

    attr_reader :school_group, :priority_action, :savings, :metric

    def initialize(school_group:, schools:, metric: [:kwh, :co2, :gbp].sample, **_kwargs)
      super
      @school_group = school_group
      @schools = schools
      @metric = metric
    end

    def render?
      total_savings.any?
    end

    def before_render
      @priority_action_alert_rating, @savings = total_savings.to_a.sample
    end

    def school_count
      I18n.t('school_count', count: @savings.schools.count)
    end

    def saving
      method = @metric == :gbp ? 'average_one_year_saving_gbp' : "one_year_saving_#{@metric}"
      format_unit(@savings.send(method),
                  @metric == :gbp ? :£ : @metric,
                  false)
    end

    def fuel_type
      I18n.t(@priority_action_alert_rating.alert_type.fuel_type, scope: 'analytics.common')
    end

    # ActionText content wraps up content in a wrapper div, usually <div class="trix-content"></div>
    # fragment returns the content without the wrapper
    def title
      @priority_action_alert_rating.current_content.management_priorities_title # .body.fragment.to_s.html_safe
    end

    private

    def total_savings
      @total_savings ||= SchoolGroups::PriorityActions.new(@schools).total_savings
    end
  end
end
