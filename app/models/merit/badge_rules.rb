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
      enrolled = lambda { |school| school.enrolled? }
      grant_on(['schools#create', 'schools#update'], to: :itself, badge: 'enrolled', temporary: true, &enrolled)

      #Rankings
      grant_on ['schools#create', 'schools#update'], to: :itself, badge: 'eco-status-bronze', temporary: true do |school|
        school.eco_school_status == 'bronze'
      end

      grant_on ['schools#create', 'schools#update'], to: :itself, badge: 'eco-status-silver', temporary: true do |school|
        school.eco_school_status == 'silver'
      end

      grant_on ['schools#create', 'schools#update'], to: :itself, badge: 'eco-status-green', temporary: true do |school|
        school.eco_school_status == 'green'
      end

      #Activity (paper)
      #Record an activity
      #Record n activities
      #Record activity in every category
      #Record all activity types in category
      #Record one activity a week for n weeks
      #
      #Added an historical activity
      #Added link and/or video to activity
      #
      #Site (bulb)
      #Logged in
      #Logged in n times? / Regular visitor
      #Viewed leaderboard
      #Early adopter (within first 6 months of ES) (special icon)
      #
      #Data (graph)
      #Explored different meters? E.g. trigger when generate graphs & signed in?
      #Viewed graphs

      # Record 10 activities
      grant_on 'activities#create', badge: 'ten-activities', multiple: true, to: :school do |activity|
        activity.school.activities.count.remainder(10).zero?
      end
    end
  end
end
