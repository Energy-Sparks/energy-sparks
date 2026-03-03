module Dashboards
  class GroupRemindersComponent < ApplicationComponent
    attr_reader :school_group, :user

    renders_one :title

    def initialize(school_group:, user:, **_kwargs)
      super
      @school_group = school_group
      @user = user
      @active_schools = school_group.schools.active.count
    end

    def prompt_for_training?
      return false if user&.admin?
      can?(:manage_settings) && user.confirmed_at > 30.days.ago
    end

    def prompt_for_onboarding?
      return false unless can?(:view_school_status)

      @school_group.onboardings_for_group.incomplete.count.positive?
    end

    def prompt_for_clusters?
      can?(:manage_clusters) && school_group.organisation? && !school_group.clusters.exists?
    end

    def prompt_for_tariff_review?
      return false unless school_group.organisation?
      can?(:manage, EnergyTariff.new(tariff_holder: @school_group)) && user.school_group == @school_group && [3, 9].include?(Time.zone.today.month)
    end

    def prompt_for_dashboard_message?
      @school_group.dashboard_message&.message
    end

    def render?
      prompt_for_onboarding? ||
        prompt_for_training? ||
        prompt_for_clusters? ||
        prompt_for_tariff_review? ||
        prompt_for_dashboard_message?
    end

    private

    def engaged_school_count
      @engaged_school_count ||= School.engaged(AcademicYear.current.start_date..).where(school_group: school_group).count
    end

    def add_prompt(list:, status:, icon:, check: true, id: nil, link: nil, path: nil)
      return unless check
      list.with_prompt id: id, status: status, icon: icon do |p|
        yield
        p.with_link { helpers.link_to I18n.t(link), path } if link
      end
    end

    def ability
      @ability ||= Ability.new(@user)
    end

    def can?(permission, context = @school_group)
      ability.can?(permission, context)
    end
  end
end
