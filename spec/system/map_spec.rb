require 'rails_helper'

RSpec.describe 'map', type: :system do
  let!(:school_1)             { create(:school, name: 'My School 1')}
  let!(:school_2)             { create(:school, name: 'My School 2')}
  let!(:school_3)             { create(:school, name: 'My School 3')}
  let!(:school_invisible)     { create(:school, name: 'Invisible School', visible: false)}

  let!(:school_group_1)       { create(:school_group, name: 'My School Group 1', schools: [school_1, school_2]) }
  let!(:school_group_2)       { create(:school_group, name: 'My School Group 2', schools: [school_3]) }

  context 'when requesting geojson' do
    it 'provides JSON for all visible schools' do
      get map_path(format: :json)
      json = JSON.parse(response.body)

      expect(json['type']).to eq('FeatureCollection')
      expect(json['features'].count).to eq(3)
    end

    it 'provides JSON for one group' do
      get map_path(school_group_id: school_group_2.id, format: :json)
      json = JSON.parse(response.body)

      expect(json['type']).to eq('FeatureCollection')
      expect(json['features'].count).to eq(1)
    end
  end

  context 'when requesting popup' do
    let!(:school_1) { create(:school, :with_fuel_configuration, number_of_pupils: 100) }

    it 'serves popup content' do
      visit map_popup_path(id: school_1.id)
      expect(page).to have_link(school_1.name, href: school_path(school_1))
      expect(page).to have_content(school_1.school_type.humanize)
      expect(page).to have_content(school_1.number_of_pupils)
      expect(page).to have_css('i.fa-bolt')
      expect(page).to have_css('i.fa-fire')
      expect(page).to have_css('i.fa-sun')
    end

    it 'sends 404 if no id' do
      visit map_popup_path
      expect(page.status_code).to eq(404)
    end
  end
end
