module Schools
  class ContactFinder
    def initialize(school)
      @school = school
    end

    def contact_for(user)
      user.contacts.where(school: @school).last || Contact.where(school: @school).where(email_address: user.email).last
    end
  end
end
