# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardingMailer2025 do
  let(:school) { create_school }
  let(:preferred_locale) { :en }
  let(:user) { create(:onboarding_user, school:, preferred_locale:) }

  before do
    create(:school_onboarding, school_name: 'Test School', created_by: user, school:, country: 'wales')
    Flipper.enable(:onboarding_mailer_2025)
  end

  around do |example|
    ClimateControl.modify(WELSH_APPLICATION_HOST: 'cy.localhost') { example.run }
  end

  def create_school(**kwargs)
    create(:school, name: 'Test School', school_group: create(:school_group), **kwargs)
  end

  def replace_variables(email_content)
    prefix = preferred_locale == :en ? '' : "#{preferred_locale}."
    ActionController::Base.helpers.sanitize(email_content.gsub('%<root_url>s', "http://#{prefix}localhost/"))
  end

  def email
    ActionMailer::Base.deliveries.last
  end

  def email_html_body_as_text
    Nokogiri::HTML(email.html_part.decoded).css('.row:nth-of-type(3)').text.gsub(/\n\s*/, "\n")
            .gsub(/[\u00A0\n]+/, "\n\n").strip
  end

  def email_html_body_as_markdown
    ReverseMarkdown.convert(Nokogiri::HTML(email.html_part.decoded).css('.row:nth-of-type(3)'))
                   .gsub("\n\n| &nbsp; |\n\n", "\n\n").gsub("| \n", '').gsub(' |', '')
                   .split("\n").map(&:strip).join("\n")
  end

  def read_md(name)
    File.read(File.join(__dir__, "#{name}.md")).gsub('[CALENDAR_ID]', school.calendar_id.to_s)
  end

  describe '#onboarded_email' do
    before do
      described_class.with_user_locales(users: [user], school: school) do |mailer|
        mailer.onboarded_email.deliver_now
      end
    end

    it 'sends the onboarded email in en' do
      expect(email.subject).to eq("#{school.name} is now live on Energy Sparks")
      puts email_html_body_as_markdown
      expect(email_html_body_as_markdown).to eq(read_md('onboarded'))
    end
  end

  describe '#welcome_email' do
    let(:school) { create_school(data_enabled: false) }

    before do
      user.after_confirmation
    end

    context 'with a school admin, not data enabled' do
      let(:user) { create(:school_admin, school:) }

      it 'sends the welcome email in en' do
        expect(email.subject).to eq('Welcome to Energy Sparks')
        expect(email_html_body_as_markdown).to eq(read_md('welcome_email_school_admin_not_data_enabled'))
      end
    end

    context 'with a staff user not data enabled' do
      let(:user) { create(:staff, school:) }

      it 'sends the welcome email in en' do
        expect(email.subject).to eq('Welcome to Energy Sparks')
        expect(email_html_body_as_markdown).to eq(read_md('welcome_email_staff_not_data_enabled'))
      end
    end

    context 'when data visible' do
      let(:school) { create_school }
      let(:user) { create(:staff, school:) }

      it 'sends the welcome email in en' do
        expect(email.subject).to eq('Welcome to Energy Sparks')
        expect(email_html_body_as_markdown).to eq(read_md('welcome_email_data_enabled'))
      end
    end
  end
end
