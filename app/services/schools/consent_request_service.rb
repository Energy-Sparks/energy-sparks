module Schools
  class ConsentRequestService
    def initialize(school)
      @school = school
    end

    def users
      users = @school.users.school_admin + @school.users.staff
      users.sort_by(&:staff_role)
    end

    def request_consent!(users)
      ConsentRequestMailer.with(emails: users.map(&:email), school: @school, subject: "We need permission to access your school's energy data").request_consent.deliver_now
    end
  end
end
