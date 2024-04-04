module Campaigns
  class ContactHandlerService
    # Unique identifier for the custom field created in Capsule for capturing
    # consent to receive marketing emails
    MARKETING_CONSENT_FIELD_ID = 830129

    def initialize(request_type, contact)
      @request_type = request_type
      @contact = contact
    end

    def perform
      party = create_party
      opportunity = create_opportunity(party)
      notify_admin(party, opportunity)
    end

    private

    def create_party
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
      tags = tags + @contact[:org_type].map { |t| { name: t } }
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
            { id: MARKETING_CONSENT_FIELD_ID, value: @contact[:consent] }
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
          name: "New Opportunity - #{@contact[:organisation]}",
          description: 'Auto-generated opportunity from campaign contact form',
          party: {
            id: party['party']['id']
          },
          tags: [
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
  end
end
