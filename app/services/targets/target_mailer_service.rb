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
      list_schools.each do |school|
        to = to(school)
        if to.any?
          TargetMailer.with(to: to, school: school).first_target.deliver_now
          school.school_target_events.create(event: :first_target_sent)
        end
      end
    end

    def invite_schools_to_review_target
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
        Targets::SchoolTargetService.new(school).enough_data?
      end
    end

    def to(school)
      #should we include cluster users might be a lot of email at start?
      users = school.school_admin.to_a + school.cluster_users.to_a + school.users.staff.to_a
      users.uniq.map(&:email)
    end
  end
end
