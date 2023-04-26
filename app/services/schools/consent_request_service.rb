module Schools
  class ConsentRequestService
    def initialize(school)
      @school = school
    end

    def users
      users = @school.all_adult_school_users
      users.sort_by(&:staff_role)
    end

    def request_consent!(users)
      ConsentRequestMailer.with_user_locales(users: users, school: @school) { |mailer| mailer.request_consent.deliver_now }
    end
  end
end
