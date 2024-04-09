require 'rails_helper'

RSpec.describe 'home', type: :system do
  it 'has a home page' do
    visit root_path
    expect(page.has_content?('Energy Sparks'))
  end

  it 'allows locale switch retaining extra parameters' do
    ClimateControl.modify FEATURE_FLAG_LOCALE_SWITCHER_BUTTONS: 'true' do
      visit root_path(foo: :bar)
      expect(page).to have_link('Cymraeg', href: 'http://cy.example.com/?foo=bar')
    end
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

    it 'redirects to campaign page' do
      visit find_out_more_path
      expect(page).to have_current_path(find_out_more_campaigns_path)
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

    it 'links to the marketing page from home page' do
      visit root_path
      click_on('Find out more')
      expect(page).to have_current_path(find_out_more_campaigns_path)
    end
  end

  it 'has a contact page' do
    visit root_path
    click_on('About')
    within('#about-menu') do
      click_on('Contact')
    end
    expect(page.has_content?('Contact us'))
  end

  it 'has a pricing page' do
    visit root_path
    click_on('Pricing')
    expect(page.has_content?('Pricing'))
  end

  describe 'having a training page' do
    let(:sold_out) { OpenStruct.new(date: DateTime.tomorrow, name: 'Event 1', url: 'http://hello', sold_out?: true) }
    let(:spaces_available) { OpenStruct.new(date: DateTime.now + 10.days, name: 'Event 2', url: 'http://hello2', sold_out?: false) }
    let(:list_events) { double('list_events') }

    before do
      visit root_path
      click_on('Our services')

      expect(Events::ListEvents).to receive(:new).and_return(list_events)
      expect(list_events).to receive(:perform).and_return([sold_out, spaces_available])

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

  it 'has a datasets page' do
    visit root_path
    click_on('About us')
    within('#about-menu') do
      click_on('Datasets')
    end
    expect(page.has_content?('Data used in Energy Sparks'))
  end

  context 'with newsletters' do
    let!(:newsletter_1) { create(:newsletter, published_on: Date.parse('01/01/2019')) }
    let!(:newsletter_2) { create(:newsletter, published_on: Date.parse('02/01/2019')) }
    let!(:newsletter_3) { create(:newsletter, published_on: Date.parse('03/01/2019')) }
    let!(:newsletter_4) { create(:newsletter, published_on: Date.parse('04/01/2019')) }

    it 'shows the latest newsletters only' do
      visit root_path

      expect(page).not_to have_content(newsletter_1.title)
      expect(page).to have_content(newsletter_2.title)
      expect(page).to have_content(newsletter_3.title)
      expect(page).to have_content(newsletter_4.title)

      click_on 'More newsletters'

      expect(page).to have_content(newsletter_1.title)
      expect(page).to have_content(newsletter_2.title)
      expect(page).to have_content(newsletter_3.title)
      expect(page).to have_content(newsletter_4.title)
    end
  end

  context 'with case studies' do
    let!(:case_study_1) { create(:case_study, position: 1) }
    let!(:case_study_2) { create(:case_study, position: 2) }
    let!(:case_study_3) { create(:case_study, position: 3) }
    let!(:case_study_4) { create(:case_study, position: 4) }

    it 'shows the latest case studies only and all on a separate page' do
      visit root_path

      expect(page).to have_content(case_study_1.title)
      expect(page).to have_content(case_study_2.title)
      expect(page).to have_content(case_study_3.title)
      expect(page).not_to have_content(case_study_4.title)

      click_on 'More case studies'

      expect(page).to have_content(case_study_1.title)
      expect(page).to have_content(case_study_2.title)
      expect(page).to have_content(case_study_3.title)
      expect(page).to have_content(case_study_4.title)
    end
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
        expect(page).not_to have_css('#my_school_menu')
        expect(page).not_to have_content('Dashboards')
      end
    end

    context 'with a visible school' do
      it 'redirects from teacher page' do
        visit "/teachers/schools/#{school.slug}"
        within('.dashboard-school-title') do
          expect(page).to have_content(school.name)
        end
      end

      it 'does not redirect to holding page' do
        expect(page).not_to have_content('Your school is currently inactive while we are setting up your energy data')
      end

      it 'does have navigation options' do
        expect(page).to have_css('#my_school_menu')
        expect(page).to have_link('Pupil dashboard')
      end
    end
  end
end
