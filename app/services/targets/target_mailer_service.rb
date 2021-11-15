module Targets
  class TargetMailerService
    def list_schools
      candidates = School.visible.data_enabled.reject {|s| s.has_target? || s.has_school_target_event?(:first_target_sent)}
      with_enough_data(candidates)
    end

    def list_schools_requiring_reminder
      candidates = School.visible.data_enabled.reject { |s| reject_for_reminder?(s) }
      with_enough_data(candidates)
    end

    def list_schools_requiring_review
      candidates = School.visible.data_enabled.reject {|s| !s.has_target? || s.has_current_target? || s.has_school_target_event?(:review_target_sent)}
      with_enough_data(candidates)
    end

    def invite_schools_to_set_first_target
      return unless EnergySparks::FeatureFlags.active?(:school_targets)
      list_schools.each do |school|
        to = to(school)
        if to.any?
          TargetMailer.with(to: to, school: school).first_target.deliver_now
          school.school_target_events.create(event: :first_target_sent)
        end
      end
    end

    def remind_schools_to_set_first_target
      return unless EnergySparks::FeatureFlags.active?(:school_targets)
      list_schools_requiring_reminder.each do |school|
        to = to(school)
        if to.any?
          TargetMailer.with(to: to, school: school).first_target_reminder.deliver_now
          school.school_target_events.create(event: :first_target_reminder_sent)
        end
      end
    end

    def invite_schools_to_review_target
      return unless EnergySparks::FeatureFlags.active?(:school_targets)
      list_schools_requiring_review.each do |school|
        to = to(school)
        if to.any?
          TargetMailer.with(to: to, school: school).review_target.deliver_now
          school.school_target_events.create(event: :review_target_sent)
        end
      end
    end

    private

    def with_enough_data(schools)
      schools.select do |school|
        Targets::SchoolTargetService.targets_enabled?(school) && Targets::SchoolTargetService.new(school).enough_data?
      end
    end

    def to(school)
      users = school.all_adult_school_users.to_a
      users.uniq.map(&:email)
    end

    def reject_for_reminder?(school)
      return true if school.has_target? || school.has_school_target_event?(:first_target_reminder_sent)
      school.school_target_events.where(event: :first_target_sent).where("created_at <= ?", 30.days.ago).empty?
    end
  end
end
