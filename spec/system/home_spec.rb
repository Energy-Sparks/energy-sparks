require 'rails_helper'

RSpec.describe "home", type: :system do
  it 'has a home page' do
    visit root_path
    expect(page.has_content? "Energy Sparks")
  end

  it 'has a teachers page' do
    visit root_path
    click_on('About')
    within('.dropdown') do
      click_on('For Teachers')
    end
    expect(page.has_content? "What is Energy Sparks?")
  end

  it 'has a contact page' do
    visit root_path
    within('.navbar-nav') do
      click_on('Contact')
    end
    expect(page.has_content? "Contact us")
  end

  it 'has an enrol page' do
    visit root_path
    click_on('About')
    within('.dropdown') do
      click_on('Enrol')
    end
    expect(page.has_content? "How do I enroll my school?")
  end

  it 'has a datasets page' do
    visit root_path
    click_on('Open data')
    expect(page.has_content? "Data used in Energy Sparks")
  end

  context 'with newsletters' do
    let!(:newsletter_1) { create(:newsletter, published_on: Date.parse('01/01/2019')) }
    let!(:newsletter_2) { create(:newsletter, published_on: Date.parse('02/01/2019')) }
    let!(:newsletter_3) { create(:newsletter, published_on: Date.parse('03/01/2019')) }
    let!(:newsletter_4) { create(:newsletter, published_on: Date.parse('04/01/2019')) }

    it 'shows the latest newsletters only' do
      visit root_path


      expect(page).to_not have_content(newsletter_1.title)
      expect(page).to have_content(newsletter_2.title)
      expect(page).to have_content(newsletter_3.title)
      expect(page).to have_content(newsletter_4.title)
    end
  end

  context 'school admin user' do
    let(:school)       { create(:school, :with_school_group, name: 'Oldfield Park Infants')}
    let(:school_admin) { create(:school_admin, school: school)}

    before(:each) do
      sign_in(school_admin)
      visit root_path
    end

    context 'with not visible school' do

      before(:each) do
        school.update(visible: false)
        visit root_path
      end

      it 'redirects to holding page' do
        expect(page).to have_content('Your school is currently inactive while we are setting up your energy data')
      end

      it 'does not have navigation options' do
        expect(page).to_not have_content('My school')
        expect(page).to_not have_content('Dashboards')
      end
    end

    context 'with a visible school' do
      it 'does not redirect to holding page' do

        expect(page).to_not have_content('Your school is currently inactive while we are setting up your energy data')
      end

      it 'does have navigation options' do
        expect(page).to have_content('My school')
        expect(page).to have_content('Dashboards')
      end
    end
  end
end
