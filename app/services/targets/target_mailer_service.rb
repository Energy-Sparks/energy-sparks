module Targets
  class TargetMailerService
    def list_schools
      candidates = School.visible.reject {|s| s.has_target? || s.has_school_target_event?(:first_target_sent)}
      with_enough_data(candidates)
    end

    def list_schools_requiring_review
      candidates = School.visible.reject {|s| !s.has_target? || s.has_current_target? || s.has_school_target_event?(:review_target_sent)}
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
  end
end
