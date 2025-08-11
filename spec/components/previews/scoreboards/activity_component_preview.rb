module Scoreboards
  class ActivityComponentPreview < ViewComponent::Preview
    # @param show_school toggle "Show school names and links"
    # @param show_date toggle "Show date activities were recorded"
    # @param show_actions toggle "Show admin buttons"
    # @param observation_style select { choices: [compact, description, full]}
    def basic_usage(show_school: true,
                    show_date: true,
                    show_actions: true,
                    observation_style: :description)
      audit = Audit.last
      observations = [
        Observation.find_by(observation_type: :activity),
        Observation.find_by(observation_type: :intervention),
        Observation.find_by(observation_type: :temperature),
        Observation.new(school: audit.school, observable: audit, observation_type: :audit_activities_completed, at: Time.zone.yesterday, points: SiteSettings.current.audit_activities_bonus_points),
        Observation.find_by(observation_type: :audit),
        Observation.find_by(observation_type: :transport_survey),
        Observation.find_by(observation_type: :programme),
        Observation.find_by(observation_type: :school_target),
      ].compact.sort_by(&:at).reverse

      render(Scoreboards::ActivityComponent.new(observations:,
                                                show_positions: false,
                                                observation_style: observation_style.to_sym,
                                                show_school:,
                                                show_date:,
                                                show_actions:))
    end

    # @param slug "Slug or id of school to show"
    # @param show_positions toggle "Show scoreboard positions"
    # @param show_school toggle "Show school names and links"
    # @param show_date toggle "Show date activities were recorded"
    # @param show_actions toggle "Show admin buttons"
    # @param observation_style select { choices: [compact, description, full]}
    def for_school(slug: nil,
                   show_positions: true,
                   show_school: true,
                   show_date: true,
                   show_actions: true,
                   observation_style: :description,
                   limit: 5)
      school = slug ? School.find(slug) : School.active.sample
      podium = Podium.create(school: school, scoreboard: school.scoreboard)
      observations = school.scoreboard.observations.for_visible_schools.not_including(school).by_date.with_points.sample(limit)
      render(Scoreboards::ActivityComponent.new(observations:,
                                                podium:,
                                                show_positions:,
                                                observation_style: observation_style.to_sym,
                                                show_school:,
                                                show_date:,
                                                show_actions:))
    end
  end
end
