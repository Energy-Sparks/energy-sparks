# frozen_string_literal: true

shared_examples 'it respects SEND_AUTOMATED_EMAILS' do
  context 'when SEND_AUTOMATED_EMAILS is false' do
    let(:send_automated_emails) { false }

    it_behaves_like 'no email is sent'
  end

  context 'when SEND_AUTOMATED_EMAILS is unset' do
    let(:send_automated_emails) { nil }

    it_behaves_like 'no email is sent'
  end
end

shared_examples 'it excludes inactive admins' do
  let(:tariff) do
    super()
    if organisation.is_a?(School)
      create(:school_admin, school: organisation, active: false)
    else
      create(:group_admin, school_group: organisation, active: false)
    end
  end

  it 'only sends to active admins' do
    expect(ActionMailer::Base.deliveries.map(&:to)).to eq([organisation.users.active.pluck(:email)])
  end

  context 'when all admins are inactive' do
    let(:tariff) do
      super()
      organisation.users.each { |user| user.update!(active: false) }
    end

    it_behaves_like 'no email is sent'
  end
end

shared_examples 'tariff reminders for an admin linked to multiple schools' do
  let(:admin) { organisation.school_admin.first }
  let(:other_school) { create(:school) }
  let(:tariff) { linked_school_users }
  let(:linked_school_users) do
    admin.cluster_schools << [organisation, other_school]
    create(:staff, school: organisation).cluster_schools << other_school
  end

  it 'sends one email per school to the admin, but not linked staff' do
    emails = ActionMailer::Base.deliveries
    expect(emails.map(&:to)).to eq([[admin.email], [admin.email]])
    expect(emails.map(&:subject)).to contain_exactly(
      I18n.t('energy_tariffs_mailer.reminder.subject', name: organisation.name),
      I18n.t('energy_tariffs_mailer.reminder.subject', name: other_school.name)
    )
  end

  context 'with an inactive linked admin' do
    let(:linked_school_users) do
      super()
      create(:school_admin, active: false).cluster_schools << [organisation, other_school]
    end

    it 'only sends to the active admin for both schools' do
      expect(ActionMailer::Base.deliveries.map(&:to)).to eq([[admin.email], [admin.email]])
    end
  end

  context 'when the linked admin is inactive' do
    let(:linked_school_users) do
      super()
      admin.update!(active: false)
    end

    it_behaves_like 'no email is sent'
  end
end
