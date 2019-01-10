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
      #1 Enrol and then sign in for the first time
      grant_on 'sessions#create', badge: 'welcome', model_name: 'User', to: :school do |user|
        user.present? && user.active_school_admin? && user.sign_in_count > 0
      end

      #2 Score some points and then view the score board
      # manually added in app/controllers/scoreboards_controller.rb

      #3 Data scientist
      #Award this if the school has creates an activity with data-scientist badge_name
      grant_on ['activities#create', 'activities#update'],
               badge: 'data-scientist', to: :school, temporary: true do |activity|
        Activity.where(activity_type: ActivityType.find_by_badge_name("data-scientist"), school: activity.school).count > 0
      end

      #4 Competitor
      # No longer used

      #5 Winner
      # No longer used

      #6 Beginner
      grant_on 'activities#create', badge: 'beginner', to: :school, temporary: true do |activity|
        activity.school.activities.count >= 1
      end

      #7 Evidence. Added link and/or video to activity
      grant_on ['activities#create', 'activities#update'], badge: 'evidence', to: :school do |activity|
        /<a href=/.match(activity.description).present?
      end

      #8 Reporter. 20 Activities
      grant_on 'activities#create', badge: 'reporter-20', temporary: true, to: :school do |activity|
        activity.school.activities.count >= 20
      end

      #9 Reporter. 50 Activities
      grant_on 'activities#create', badge: 'reporter-50', temporary: true, to: :school do |activity|
        activity.school.activities.count >= 50
      end

      #10 Reporter. 100 Activities
      grant_on 'activities#create', badge: 'reporter-100', temporary: true, to: :school do |activity|
        activity.school.activities.count >= 100
      end

      category_check = lambda { |school, badge_name, count|
        counts = school.activities.where(activity_category: ActivityCategory.find_by_badge_name(badge_name)).group(:activity_type_id).count
        counts.keys.length > count
      }

      #11 Investigator. Record 5 different types of activity in the "Investigating energy usage" category
      grant_on ['activities#create', 'activities#update'],
               badge: 'investigator', to: :school, temporary: true do |activity|
        category_check.call(activity.school, "investigator", 5)
      end

      #12 Learner  Record 5 different types of activity in the "Learning" category
      grant_on ['activities#create', 'activities#update'],
               badge: 'learner', to: :school, temporary: true do |activity|
        category_check.call(activity.school, "learner", 5)
      end

      #13 Communicator  Record 5 different types of activity in the "Spreading the message" category
      grant_on ['activities#create', 'activities#update'],
               badge: 'communicator', to: :school, temporary: true do |activity|
        category_check.call(activity.school, "communicator", 5)
      end

      #14 Energy Saver  Record 5 different types of activity in the "Taking action around the school" category
      grant_on ['activities#create', 'activities#update'],
               badge: 'energy-saver', to: :school, temporary: true do |activity|
        category_check.call(activity.school, "energy-saver", 5)
      end

      #15 Teamwork  Record 5 different types of activity in the "Whole-school activities" category
      grant_on ['activities#create', 'activities#update'],
               badge: 'teamwork', to: :school, temporary: true do |activity|
        category_check.call(activity.school, "teamwork", 5)
      end

      #16 Explorer  Record one activity in each category
      grant_on ['activities#create', 'activities#update'], badge: 'explorer', to: :school, temporary: true do |activity|
        counts = activity.school.activities.group(:activity_category_id).count
        counts.keys.length == ActivityCategory.count
      end

      period_check = lambda {|school, from_date, to_date, count|
        counts = school.activities.where("happened_on >= ? and happened_on <= ?", from_date, to_date).group_by_week(:happened_on).count
        counts.keys.length >= count
      }

      #17 Autumn Term  At least 8 activities in different weeks
      grant_on ['activities#create', 'activities#update'], badge: 'autumn-term', to: :school, temporary: true do |activity|
        period_check.call(activity.school, Date.parse("#{Time.zone.today.year}-09-01"), Date.parse("#{Time.zone.today.year}-12-31"), 8)
      end

      #18 Spring Term  At least one activity per week
      grant_on ['activities#create', 'activities#update'], badge: 'spring-term', to: :school, temporary: true do |activity|
        period_check.call(activity.school, Date.parse("#{Time.zone.today.year}-01-01"), Date.parse("#{Time.zone.today.year}-03-31"), 8)
      end

      #19 Summer Term  At least one activity per week
      grant_on ['activities#create', 'activities#update'], badge: 'summer-term', to: :school, temporary: true do |activity|
        period_check.call(activity.school, Date.parse("#{Time.zone.today.year}-04-01"), Date.parse("#{Time.zone.today.year}-07-01"), 8)
      end

      #20 Graduate  Get all term badges
      grant_on ['activities#create', 'activities#update'], badge: 'graduate', to: :school, temporary: true do |activity|
        activity.school.badges.include?(Merit::Badge.find(17)) && activity.school.badges.include?(Merit::Badge.find(18)) && activity.school.badges.include?(Merit::Badge.find(19))
      end
    end
  end
end
