# frozen_string_literal: true

module SchoolGroups
  module ImpactReport
    class Generator
      class Engagement < Base
        METRIC_CATEGORY = :engagement
        METRICS = %i[activities actions points targets].freeze

        private

        def value(metric) = send(metric[:metric_type])

        def activities
          Activity.between(twelve_months_ago, generated_at)
                  .joins(:school)
                  .merge(visible_schools)
                  .count
        end

        def actions
          Observation.intervention
                     .between(twelve_months_ago, generated_at)
                     .joins(:school)
                     .merge(visible_schools)
                     .count
        end

        def points
          Observation.between(twelve_months_ago, generated_at)
                     .joins(:school)
                     .merge(visible_schools)
                     .sum(:points)
        end

        def programmes
          Programme.completed
                   .where(created_at: twelve_months_ago..)
                   .joins(:school)
                   .merge(visible_schools)
                   .count
        end

        def targets
          SchoolTarget.currently_active
                      .joins(:school)
                      .merge(visible_schools)
                      .count
        end
      end
    end
  end
end
