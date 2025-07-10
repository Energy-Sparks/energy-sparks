require 'rails_helper'

RSpec.describe 'home', type: :system do
  describe 'Home page' do
    it 'has a home page' do
      visit root_path
      expect(page).to have_content 'Helping schools cut energy costs and fight climate change'
    end

    context 'with all components available' do
      include_context 'with blog cache'

      before do
        create(:testimonial, category: :default)
        visit root_path
      end

      it 'renders all the components' do
        expect(page).to have_css('#hero')
        expect(page).to have_css('#stats-header')
        expect(page).to have_css('#stats')
        expect(page).to have_css('#testimonials')
        expect(page).to have_css('#features-header')
        expect(page).to have_css('#features')
        expect(page).to have_css('#buttons')
        expect(page).to have_css('#general')
        expect(page).to have_css('#organisations-header')
        expect(page).to have_css('#organisations')
        expect(page).to have_css('#blog-header')
        expect(page).to have_css('#blog')
      end
    end

    context 'without blog cache' do
      before do
        visit root_path
      end

      it 'does not render the blog components' do
        expect(page).not_to have_css('#blog-header')
        expect(page).not_to have_css('#blog')
      end
    end

    context 'without any tesimonials in the :default category' do
      before do
        create(:testimonial, category: :audit)
        visit root_path
      end

      it 'does not render the tesimonials component' do
        expect(page).not_to have_css('#testimonials')
      end
    end
  end

  describe 'Energy audits page' do
    context 'with all components available' do
      before do
        create(:testimonial, category: :audit)
        visit energy_audits_path
      end

      it 'renders all the components' do
        expect(page).to have_css('#hero')
        expect(page).to have_css('#onsite')
        expect(page).to have_css('#onsite-prices')
        expect(page).to have_css('#desktop')
        expect(page).to have_css('#testimonials')
      end
    end

    context 'without tesimonials in the :audit category' do
      before do
        create(:testimonial, category: :default)
        visit energy_audits_path
      end

      it 'does not render the tesimonials component' do
        expect(page).not_to have_css('#testimonials')
      end
    end
  end

  describe 'Education workshops page' do
    before do
      visit education_workshops_path
    end

    it 'renders all the components' do
      expect(page).to have_css('#hero')
      expect(page).to have_css('#workshops-header')
      expect(page).to have_css('#workshops')
      expect(page).to have_css('#audience')
      expect(page).to have_css('#details')
    end
  end

  it 'allows locale switch retaining extra parameters' do
    visit root_path(foo: :bar)
    expect(page).to have_link('Cymraeg', href: 'http://cy.example.com/?foo=bar')
  end

  context 'with marketing pages' do
    let(:case_study) { create(:case_study) }

    before do
      allow(CaseStudy).to receive(:find).and_return(case_study)
    end

    it 'has a for-schools page' do
      visit root_path
      click_on('Our services')
      within('#our-services') do
        click_on('For Schools')
      end
      expect(page).to have_current_path(find_out_more_campaigns_path)
    end

    it 'redirects old pages' do
      get for_teachers_path
      expect(response).to redirect_to(for_schools_path)

      get for_pupils_path
      expect(response).to redirect_to(for_schools_path)

      get for_management_path
      expect(response).to redirect_to(for_schools_path)
    end

    it 'routes to the campaign page' do
      visit find_out_more_path
      expect(page).to have_content(I18n.t('campaigns.find_out_more.title'))
    end

    it 'has a for-local-authorities page' do
      visit root_path
      click_on('Our services')
      within('#our-services') do
        click_on('For Local Authorities')
      end
      expect(page).to have_current_path(find_out_more_campaigns_path)
    end

    it 'has a for-multi-academy-trusts page' do
      visit root_path
      click_on('Our services')
      within('#our-services') do
        click_on('For Multi-Academy Trusts')
      end
      expect(page).to have_current_path(find_out_more_campaigns_path)
    end
  end

  describe 'Contact page' do
    before do
      visit root_path
      click_on('About')
      within('#about-menu') do
        click_on('Contact')
      end
    end

    it { expect(page).to have_content('Contact us') }
  end

  describe 'Team page' do
    before do
      visit root_path
      click_on('About')
      within('#about-menu') do
        click_on('Team')
      end
    end

    it { expect(page).to have_content('Our Team') }
  end

  describe 'Pricing page' do
    context toggle_feature: :new_pricing_page do
      it 'has a pricing page' do
        visit root_path
        click_on('Pricing')
        expect(page.has_content?('Pricing'))
      end
    end

    context 'with all components available', with_feature: :new_pricing_page do
      before do
        visit pricing_path
      end

      it 'renders all the components' do
        expect(page).to have_css('#hero')
        expect(page).to have_css('#features')
        expect(page).to have_css('#looking-for-info')
        expect(page).to have_css('#audience')
        expect(page).to have_css('#prices')
        expect(page).to have_css('#additional-services')
        expect(page).to have_css('#general')
      end
    end
  end

  it 'has a support us page' do
    visit root_path
    click_on('Support us')
    expect(page.has_content?('Support us'))
  end

  describe 'Training page' do
    context without_feature: :new_training_page do
      let(:sold_out) { OpenStruct.new(date: DateTime.tomorrow, name: 'Event 1', url: 'http://hello', sold_out?: true) }
      let(:spaces_available) { OpenStruct.new(date: DateTime.now + 10.days, name: 'Event 2', url: 'http://hello2', sold_out?: false) }
      let(:list_events) { double('list_events') }

      before do
        visit root_path
        click_on('Our services')

        expect(Events::ListEvents).to receive(:new).and_return(list_events)
        expect(list_events).to receive(:events_without_images).and_return([])
        expect(list_events).to receive(:events).and_return([sold_out, spaces_available])

        within('#our-services') do
          click_on('Training')
        end
      end

      it { expect(page).to have_content('Training') }

      it 'has available event' do
        expect(page).to have_content('Event 1')
        expect(page).to have_content('Spaces available')
      end

      it 'has sold out event' do
        expect(page).to have_content('Event 2')
        expect(page).to have_content('Sold out')
      end
    end

    context with_feature: :new_training_page do
      let(:response) { JSON.parse(File.read(File.join(fixture_paths.first, 'events/events.json'))) }

      before do
        allow(EventbriteSDK).to receive(:get).and_return(response)
        visit root_path
        click_on('Our services')
        within('#our-services') do
          click_on('Training')
        end
      end

      let(:displayed_events) { all('#events .card') }

      context 'when there are events' do
        let(:available) { displayed_events[0] }
        let(:sold_out) { displayed_events[3] }

        it { expect(page).to have_css('#events') }
        it { expect(displayed_events.count).to eq 4 }
        it { expect(page).to have_content('Training') }
        it { expect(page).to have_content('This page lists all of our upcoming training sessions. Follow the links to our Eventbrite page to book your tickets.') }

        it 'has available event' do
          expect(available).to have_css("img[src*='https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F113596237%2F481005514167%2F1%2Foriginal.20201005-092822?h=200&w=450&auto=format%2Ccompress&q=75&sharp=10&rect=0%2C161%2C1086%2C543&s=1279466ca350155300d6b315d128f3d9']")
          expect(available).to have_content('Energy Sparks induction session')
          expect(available).to have_content('An online induction to help you get started reducing energy consumption with Energy Sparks.')
          expect(available).to have_content('Spaces available')
          expect(available).to have_link('Sign up', href: 'https://www.eventbrite.co.uk/e/energy-sparks-induction-session-tickets-138294742297')
        end

        it 'has sold out event' do
          expect(sold_out).to have_css("img[src*='https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F113596237%2F481005514167%2F1%2Foriginal.20201005-092822?h=200&w=450&auto=format%2Ccompress&q=75&sharp=10&rect=0%2C161%2C1086%2C543&s=1279466ca350155300d6b315d128f3d9']")
          expect(sold_out).to have_content('Another Energy Sparks induction session')
          expect(sold_out).to have_content('Another online induction to help you get started reducing energy consumption with Energy Sparks.')
          expect(sold_out).to have_content('Sold out')
          expect(sold_out).to have_link('More information', href: 'https://www.eventbrite.co.uk/e/energy-sparks-induction-session-tickets-141010286563')
        end
      end

      context 'when there are no events' do
        let(:response) { { 'events': [] } }

        it { expect(page).not_to have_css('#events') }
        it { expect(displayed_events.count).to eq 0 }
        it { expect(page).to have_content('No events are currently scheduled')}
        it { expect(page).to have_content('New events are added regularly, so please check again soon')}
      end
    end
  end

  describe 'Newsletters page' do
    before do
      visit root_path
      click_on('Newsletters')
    end

    it { expect(page).to have_content('Newsletters') }
  end

  describe 'Datasets page' do
    before do
      visit root_path
      click_on('Datasets')
    end

    it { expect(page).to have_content('Dataset attributions') }
  end

  describe 'Open data page' do
    before do
      visit root_path
      click_on('Open data')
    end

    it { expect(page).to have_content('Data used in Energy Sparks') }
  end

  describe 'School statistics page' do
    before do
      visit root_path
      within('footer') do
        click_on('School statistics')
      end
    end

    it { expect(page).to have_content('School Statistics') }
  end

  context 'school admin user' do
    let(:school)       { create(:school, :with_school_group, name: 'Oldfield Park Infants')}
    let(:school_admin) { create(:school_admin, school: school)}

    before do
      sign_in(school_admin)
      visit root_path
    end

    context 'with not visible school' do
      before do
        school.update(visible: false)
        visit root_path
      end

      it 'redirects to holding page' do
        expect(page).to have_content('We are still in the process of setting up your school on Energy Sparks')
      end

      it 'does not have navigation options' do
        expect(page).not_to have_css('#my-school-menu')
        expect(page).not_to have_content('Dashboards')
      end
    end
  end
end
