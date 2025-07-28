module Campaigns
  class ContactHandlerService
    # Unique identifier for the custom field created in Capsule for capturing
    # consent to receive marketing emails
    MARKETING_CONSENT_FIELD_ID = 830129
    NEW_MILESTONE_ID = 2041588

    def initialize(request_type, contact)
      @request_type = request_type
      @contact = contact
    end

    def perform
      party = create_party
      opportunity = create_opportunity(party)
      notify_admin(party, opportunity)
      email_user
    end

    private

    def create_party
      return nil unless can_create_party?
      party = create_party_from_contact
      CapsuleCrm::Client.new.create_party(party)
    rescue => e
      Rails.logger.error("Error: #{e.message} when creating party in CapsuleCRM")
      Rollbar.warning(e, job: :capsulecrm)
      nil
    end

    def create_party_from_contact
      tags = [
        { name: 'Campaign' },
        { name: @request_type.to_s.humanize }
      ]
      tags = tags + [{ name: @contact[:org_type]&.to_s&.humanize }]
      {
        party: {
          type: :person,
          firstName: @contact[:first_name],
          lastName: @contact[:last_name],
          jobTitle: @contact[:job_title],
          organisation: { name: @contact[:organisation] },
          emailAddresses: [{ address: @contact[:email] }],
          phoneNumbers: [{ number: @contact[:tel] }],
          tags: tags,
          fields: [
            { definition: { id: MARKETING_CONSENT_FIELD_ID }, value: @contact[:consent] }
          ]
        }
      }
    end

    def create_opportunity(party)
      return nil unless party.present?
      opportunity = create_opportunity_for_party(party)
      CapsuleCrm::Client.new.create_opportunity(opportunity)
    rescue => e
      Rails.logger.error("Error: #{e.message} when creating opportunity in CapsuleCRM")
      Rollbar.warning(e, job: :capsulecrm)
      nil
    end

    def create_opportunity_for_party(party)
      {
        opportunity: {
          name: @contact[:organisation],
          description: 'Auto-generated opportunity from campaign contact form',
          milestone: { id: NEW_MILESTONE_ID },
          party: {
            id: party['party']['id']
          },
          tags: [
            { name: 'Campaign' },
            { name: @request_type.to_s.humanize }
          ]
        }
      }
    end

    def notify_admin(party, opportunity)
      CampaignMailer.with(request_type: @request_type,
                       contact: @contact,
                       party: party,
                       opportunity: opportunity).notify_admin.deliver_now
    end

    def email_user
      if @request_type == :school_info
        CampaignMailer.with(contact: @contact).send_information_school.deliver_now
      elsif @request_type == :group_info
        CampaignMailer.with(contact: @contact).send_information_group.deliver_now
      elsif @request_type == :school_demo
        CampaignMailer.with(contact: @contact).school_demo.deliver_now
      end
    end

    # Attempt Capsule integration in dev/test to allow mocking in specs
    # and manual tests. Otherwise only do the Capsule api calls
    # from the production server.
    def can_create_party?
      return true unless Rails.env.production?
      return ENV['ENVIRONMENT_IDENTIFIER'] != 'test'
    end
  end
end
