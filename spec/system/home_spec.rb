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
    click_on('About')
    within('.dropdown') do
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
end