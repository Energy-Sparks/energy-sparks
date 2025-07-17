require 'rails_helper'

RSpec.describe 'Navigation -> top nav', type: :system do
  let(:nav) { page.find(:css, 'nav.navbar-top') }
  let(:locale) { :en }
  let(:user) {}

  before do
    sign_in(user) if user
    visit root_path(locale: locale)
  end

  it 'links to pupil activities' do
    expect(nav).to have_link 'Activities', href: activity_categories_path
  end

  it 'links to adult actions' do
    expect(nav).to have_link 'Actions', href: intervention_type_groups_path
  end

  it 'links to Our schools menu' do
    expect(nav).to have_link 'Our schools'
  end

  context 'with an Our schools menu' do
    let(:our_schools) { nav.find(:css, '#our-schools') }

    it 'has all menu options' do
      expect(our_schools).to have_link('View schools')
      expect(our_schools).to have_link('Scoreboards')
      expect(our_schools).to have_link('Compare schools')
    end
  end

  it 'links to Our services menu' do
    expect(nav).to have_link 'Our services'
  end

  context 'with an Our services menu' do
    let(:our_services) { nav.find(:css, '#our-services') }

    it 'has all menu options' do
      expect(our_services).to have_link('Energy management tool')
      expect(our_services).to have_link('Energy audits')
      expect(our_services).to have_link('Education workshops')
      expect(our_services).to have_link('Training')
      expect(our_services).to have_link('Case studies')
      expect(our_services).to have_link('Newsletters')
      expect(our_services).to have_link('Videos')
    end
  end

  it 'links to About us menu' do
    expect(nav).to have_link 'About us'
  end

  context 'with an About us menu' do
    let(:about_us) { nav.find(:css, '#about-us') }

    it 'has all menu options' do
      expect(about_us).to have_link('Contact')
      expect(about_us).to have_link('Team')
      expect(about_us).to have_link('Blog')
      expect(about_us).to have_link('Our funders')
      expect(about_us).to have_link('Jobs')
      expect(about_us).to have_link('Terms and conditions')
      expect(about_us).to have_link('Privacy policy')
      expect(about_us).to have_link('Child safeguarding')
      expect(about_us).to have_link('School statistics')
    end
  end

  it 'links to support us' do
    expect(nav).to have_link 'Support us', href: support_us_path
  end

  it 'does not link to manage menu' do
    expect(nav).not_to have_link 'Manage'
  end

  context 'when admin' do
    let(:user) { create(:admin) }

    it 'links to manage menu' do
      expect(nav).to have_link 'Manage'
    end

    context 'with a Manage menu' do
      let(:manage) { nav.find(:css, '#manage') }

      it 'has all menu options' do
        expect(manage).to have_link('Admin')
        expect(manage).to have_link('Reports')
      end
    end
  end

  context 'with a locale switcher' do
    context 'when locale is "en"' do
      let(:locale) { :en }

      it 'locale switcher is "Cymraeg"' do
        expect(nav).to have_link 'Cymraeg'
      end
    end

    context 'when locale is "cy"' do
      let(:locale) { :cy }

      it 'locale switcher is "English"' do
        expect(nav).to have_link 'English'
      end
    end
  end
end
