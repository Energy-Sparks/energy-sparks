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
      can_manage_group? && user.confirmed_at > 30.days.ago
    end

    def prompt_for_clusters?
      can_manage_group? && !school_group.clusters.exists?
    end

    def prompt_for_tariff_review?
      can_manage_group? && [3, 9].include?(Time.zone.today.month)
    end

    # This will need review from the team
    def prompt_for_engagement?
      can_manage_group? && @active_schools.positive? && low_engagement?
    end

    def prompt_for_onboarding?
      @school_group.school_onboardings.incomplete.count.positive?
    end

    private

    def low_engagement?
      (engaged_school_count.to_f / @active_schools) < 0.5
    end

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

    def can_manage_group?
      return true if user&.admin?
      can?(:show_management_dash, @school_group) && user.school_group == @school_group
    end

    def ability
      @ability ||= Ability.new(@user)
    end

    def can?(permission, context)
      ability.can?(permission, context)
    end
  end
end
