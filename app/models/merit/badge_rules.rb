# Be sure to restart your server when you modify this file.
#
# +grant_on+ accepts:
# * Nothing (always grants)
# * A block which evaluates to boolean (recieves the object as parameter)
# * A block with a hash composed of methods to run on the target object with
#   expected values (+votes: 5+ for instance).
#
# +grant_on+ can have a +:to+ method name, which called over the target object
# should retrieve the object to badge (could be +:user+, +:self+, +:follower+,
# etc). If it's not defined merit will apply the badge to the user who
# triggered the action (:action_user by default). If it's :itself, it badges
# the created object (new user for instance).
#
# The :temporary option indicates that if the condition doesn't hold but the
# badge is granted, then it's removed. It's false by default (badges are kept
# forever).

module Merit
  class BadgeRules
    include Merit::BadgeRulesMethods

    def initialize
      # Sign up to EnergySparks
      grant_on ['schools#create', 'schools#update'], to: :itself, badge: 'enrolled', temporary: true do |school|
        school.enrolled?
      end

      # Sign up to eco-schools programme i.e. eco_school_status is not null
      grant_on ['schools#create', 'schools#update'], to: :itself, badge: 'eco-enrolled', temporary: true do |school|
        school.eco_school_status.present?
      end

      # Gain highest eco-school ranking
      grant_on ['schools#create', 'schools#update'], to: :itself, badge: 'eco-status-green', temporary: true do |school|
        school.eco_school_status == 'green'
      end

      # Record 10 activities
      grant_on 'activities#create', badge: 'ten-activities', multiple: true, to: :school do |activity|
        activity.school.activities.count.remainder(10).zero?
      end
    end
  end
end
