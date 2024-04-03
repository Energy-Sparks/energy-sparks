class CampaignMailerPreview < ActionMailer::Preview
  def notify_admin
    request_type = :book_now
    contact = {
      first_name: 'Jane',
      last_name: 'Smith',
      email: 'jane@example.org',
      tel: '01225 444444',
      job_title: 'CFO',
      organisation: 'Fake Academies',
      org_type: :mat,
      consent: true
    }
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
                     contact: contact,
                     party: party,
                     opportunity: opportunity).notify_admin
  end
end
