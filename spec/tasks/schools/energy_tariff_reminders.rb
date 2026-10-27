# frozen_string_literal: true

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
end
