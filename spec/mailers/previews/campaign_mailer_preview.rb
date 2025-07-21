class CampaignMailerPreview < ActionMailer::Preview
  def notify_admin
    request_type = :school_demo
    party = {
      'party' => {
        'id' => 1234
      }
    }
    opportunity = {
      'opportunity' => {
        'id' => 1234
      }
    }
    CampaignMailer.with(request_type: request_type,
                     contact: contact(['primary']),
                     party: party,
                     opportunity: opportunity).notify_admin
  end

  def send_information
    org_type = if params[:org_type]
                 [params[:org_type]]
               else
                 %w[primary multi_academy_trust].sample(1)
               end
    CampaignMailer.with(contact: contact(org_type)).send_information
  end

  def school_demo
    org_type = if params[:org_type]
                 [params[:org_type]]
               else
                 %w[primary secondary].sample(1)
               end
    CampaignMailer.with(contact: contact(org_type)).school_demo
  end

  private

  def contact(org_type)
    {
      first_name: 'Jane',
      last_name: 'Smith',
      email: 'jane@example.org',
      tel: '01225 444444',
      job_title: 'CFO',
      organisation: 'Fake Academies',
      org_type: org_type,
      consent: true
    }
  end
end
