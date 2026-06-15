# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardLoginComponent, :include_url_helpers, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:school) { create(:school) }
  let(:classes) { 'my-class' }
  let(:id) { 'my-id' }
  let(:user) { nil }
  let(:params) do
    {
      school: school,
      user: user,
      id: id,
      classes: classes
    }
  end

  let(:html) do
    render_inline(component)
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end

  context 'with no user' do
    it { expect(component.render?).to be true }
  end

  context 'with guest' do
    let(:user) { create(:guest) }

    it { expect(component.render?).to be true }
  end

  context 'with school_admin' do
    let(:user) { create(:school_admin) }

    it { expect(component.render?).to be false }
  end

  it { expect(html).to have_content(I18n.t('role.staff')) }
  it { expect(html).to have_content(I18n.t('role.pupil')) }

  it 'links to staff login form' do
    expect(html).to have_link(I18n.t('devise.sessions.new.log_in_with_your_email_address_and_password'),
                              href: new_user_session_path(role: :staff, school: school))
  end

  it 'links to pupil login form' do
    expect(html).to have_link(I18n.t('devise.sessions.new.log_in_with_your_pupil_password'),
                              href: new_user_session_path(role: :pupil, school: school))
  end
end
