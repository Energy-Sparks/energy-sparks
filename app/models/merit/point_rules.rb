# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
#
# Points are a simple integer value which are given to "meritable" resources
# according to rules in +app/models/merit/point_rules.rb+. They are given on
# actions-triggered, either to the action user or to the method (or array of
# methods) defined in the +:to+ option.
#
# 'score' method may accept a block which evaluates to boolean
# (recieves the object as parameter)

module Merit
  class PointRules
    include Merit::PointRulesMethods

    def initialize
      # Enroll in EnergySparks

      activity_score = ->(activity) { activity.activity_type.score }
      negativity_activity_score = ->(activity) { -activity.activity_type.score }

      # Award points schools and for activities
      recent = ->(activity) { activity.happened_on > Time.zone.today - 6.months }
      score(activity_score, to: :school, on: ['activities#create'], &recent)
      # Note: this does mean that if we delete an activity that's > 6 months old we won't
      # remove the points. Difficult to do anything else for the minute unless we can track
      # why points were awarded
      score(negativity_activity_score, to: :school, on: ['activities#destroy'], &recent)
    end
  end
end
