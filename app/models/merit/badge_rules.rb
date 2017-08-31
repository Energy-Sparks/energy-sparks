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
#
#
# Note: changing the ordering here may impact some of the unit tests...
module Merit
  class BadgeRules
    include Merit::BadgeRulesMethods

    def initialize
      # Sign up to EnergySparks
      enrolled = lambda { |school| school.enrolled? }
      grant_on(['schools#create', 'schools#update'], to: :itself, badge: 'enrolled', temporary: true, &enrolled)

      #Activity (paper)
      #Record an activity
      grant_on 'activities#create', badge: 'first-activity', to: :school, temporary: true do |activity|
        activity.school.activities.count >= 1
      end

      # Record n activities
      # Record 10 activities
      grant_on 'activities#create', badge: 'ten-activities', multiple: true, to: :school do |activity|
        activity.school.activities.count.remainder(10).zero?
      end

      #Record an activity in every category
      #FIX Record all activities within a category (except, "Other")
      grant_on ['activities#create', 'activities#update'], badge: 'all-categories', to: :school, temporary: true do |activity|
        counts = activity.school.activities.group(:activity_category_id).count
        counts.keys.length == ActivityCategory.count
      end

      #Record one of every type of activity
      grant_on ['activities#create', 'activities#update'], badge: 'all-activities', to: :school, temporary: true do |activity|
        counts = activity.school.activities.group(:activity_type_id).count
        counts.keys.length == ActivityType.count
      end

      #These need to be scoped to a term
      #Record at least one activity a week for 8 weeks. Permanent. Sharing
      #Continuing to record at least one activity a week for 4 weeks. Temporary. Energy Monitor

      #Added link and/or video to activity. Evidence
      grant_on ['activities#create', 'activities#update'], badge: 'evidence', to: :school do |activity|
        /<a href=/.match(activity.description).present?
      end

      #Record an "Other" activity?

      #Activities
      #Added an historical activity
      #But historical activities (>2 months ago) shouldn't score points

      #Site (bulb)
      #Logged in. Welcome!
      #Logged in n times? / Regular visitor
      grant_on 'sessions#create', badge: 'first-steps', model_name: 'User', to: :school do |user|
        user.present? && user.school_admin? && user.sign_in_count > 0
      end

      #Site (bulb)
      grant_on ['schools#leaderboard'], badge: 'player', model_name: 'User', to: :school do |user|
        user.present? && user.school_admin? && user.school.enrolled?
      end

      #Player, Viewed leaderboard

      #Competitor
      #Winner

      #Data (graph)
      #Explored different meters? E.g. trigger when generate graphs & signed in?
      #Viewed graphs
    end
  end
end
