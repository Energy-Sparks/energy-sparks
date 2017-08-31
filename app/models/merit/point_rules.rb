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
      enrolled = lambda { |school| school.enrolled? }
      score(20, to: :itself, on: ['schools#update'], &enrolled)

      activity_score = lambda { |activity| activity.activity_type.score }
      negativity_activity_score = lambda { |activity| -activity.activity_type.score }

      # Award points schools and for activities
      score activity_score, to: :school, on: [
        'activities#create'
      ]
      score(negativity_activity_score, to: :school, on: [
        'activities#destroy'
      ])
    end
  end
end
