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
      ConsentRequestMailer.with(users: users, school: @school).request_consent.deliver_now
    end
  end
end
