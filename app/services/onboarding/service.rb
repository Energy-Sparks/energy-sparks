module Onboarding
  class Service
    include Wisper::Publisher

    def complete_onboarding(school_onboarding, users)
      school_onboarding.events.create(event: :onboarding_complete)
      school_onboarding.school.update!(visible: true)
      send_confirmation_instructions(users)
      enrol_in_default_programme(school_onboarding.school)
      broadcast(:onboarding_completed, school_onboarding)
    end

    def should_complete_onboarding?(school)
      school.school_onboarding && school.school_onboarding.incomplete?
    end

    def record_event(onboarding, *events)
      result = yield if block_given?
      if onboarding
        events.each do |event|
          onboarding.events.create(event: event)
        end
      end
      result
    end

    private

    def enrol_in_default_programme(school)
      Programmes::Enroller.new.enrol(school)
    end

    def send_confirmation_instructions(users)
      users.each do |user|
        user.send_confirmation_instructions unless user.confirmed?
      end
    end
  end
end
