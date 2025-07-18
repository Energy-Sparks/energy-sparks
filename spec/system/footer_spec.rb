require 'rails_helper'

RSpec.describe 'Footer', type: :system do
  before do
    Flipper.enable :footer
    visit terms_and_conditions_path # visit a link that doesn't hit the db for test speed
  end

  describe 'Top Footer' do
    describe 'Quick Links' do
      let(:block) { page.find(:css, 'footer .footer-top #quick-links') }

      it { expect(block).to have_content 'Quick Links' }
      it { expect(block).to have_link 'Activities', href: activity_categories_path }
      it { expect(block).to have_link 'Actions', href: intervention_type_groups_path }
      it { expect(block).to have_link 'View schools', href: schools_path }
      it { expect(block).to have_link 'Scoreboards', href: scoreboards_path }
      it { expect(block).to have_link 'Contact', href: contact_path }
    end

    describe 'Services' do
      let(:block) { page.find(:css, 'footer .footer-top #services') }

      it { expect(block).to have_content 'Services' }
      it { expect(block).to have_link 'Energy management tool', href: product_path }
      it { expect(block).to have_link 'Energy audits', href: energy_audits_path }
      it { expect(block).to have_link 'Education workshops', href: education_workshops_path }
      it { expect(block).to have_link 'Training', href: training_path }
      it { expect(block).to have_link 'Watch a demo', href: book_demo_campaigns_path }
      it { expect(block).to have_link 'Case studies', href: case_studies_path }
    end

    describe 'Other Links' do
      let(:block) { page.find(:css, 'footer .footer-top #other-links') }

      it { expect(block).to have_content 'Other Links' }
      it { expect(block).to have_link 'Jobs', href: jobs_path }
      it { expect(block).to have_link 'Blog', href: 'http://blog.energysparks.uk' }
      it { expect(block).to have_link 'School statistics', href: school_statistics_path }
      it { expect(block).to have_link 'Datasets', href: attribution_path }
      it { expect(block).to have_link 'Open data', href: datasets_path }
    end

    describe 'Legal Terms' do
      let(:block) { page.find(:css, 'footer .footer-top #legal-terms') }

      it { expect(block).to have_content 'Legal Terms' }
      it { expect(block).to have_link 'Terms and conditions', href: terms_and_conditions_path }
      it { expect(block).to have_link 'Privacy policy', href: privacy_and_cookie_policy_path }
      it { expect(block).to have_link 'Cookies', href: cookies_path }
      it { expect(block).to have_link 'Child safeguarding policy', href: child_safeguarding_policy_path }
    end

    describe 'Newsletter Signup' do
      let(:block) { page.find(:css, 'footer .footer-top #newsletter-signup') }

      it { expect(block).to have_content 'Newsletter Signup' }
      it { expect(block).to have_content 'Get the latest news from Energy Sparks in your inbox' }
      it { expect(block).to have_field :email_address, placeholder: 'eg: hello@example.com' }
      it { expect(block).to have_button('Sign-up now') }
      it { expect(block).to have_content "We'll never share your email with anyone else" }

      context 'when user is signed in' do
        before do
          sign_in(create(:school_admin))
          refresh
        end

        it { expect(block).to have_content 'Newsletter Signup' }
        it { expect(block).to have_content 'Get the latest news from Energy Sparks in your inbox' }
        it { expect(block).not_to have_field :email_address, placeholder: 'eg: hello@example.com' }
        it { expect(block).to have_button('Sign-up now') }
        it { expect(block).to have_content "We'll never share your email with anyone else" }
      end

      context 'when user is signed in', with_feature: :profile_pages do
        let(:user) { create(:school_admin) }

        before do
          sign_in(user)
          refresh
        end

        it { expect(block).to have_content 'Newsletter Signup' }
        it { expect(block).to have_content 'Get the latest news from Energy Sparks in your inbox' }
        it { expect(block).to have_link('Sign-up now', href: user_emails_path(user)) }
      end
    end
  end

  describe 'Second Footer' do
    let(:block) { page.find(:css, 'footer .footer-second') }

    it { expect(block).to have_content 'Content on this website is published under a Creative Commons Attribution 4.0 Licence.' }
    it { expect(block).to have_content 'Energy Sparks is a registered charity in England and Wales, registration 1189273.' }

    it { expect(block).to have_link href: 'https://creativecommons.org/licenses/by/4.0/' }
    it { expect(block).to have_link href: 'https://www.linkedin.com/company/energy-sparks/' }
    it { expect(block).to have_link href: 'https://x.com/EnergySparks' }
    it { expect(block).to have_link href: 'https://www.instagram.com/energysparksuk/' }
    it { expect(block).to have_link href: 'https://www.facebook.com/EnergySparksUK/' }
    it { expect(block).to have_link href: 'https://github.com/energy-sparks/energy-sparks' }
  end
end
