require 'rails_helper'

RSpec.describe 'editing school configuration', type: :system do
  let!(:admin)              { create(:admin)}
  let!(:school)             { create(:school)}

  before do
    sign_in(admin)
    visit school_path(school)
  end

  context 'when editing basic configuration' do
    let!(:school_group) { create(:school_group) }
    let!(:scoreboard) { create(:scoreboard) }
    let!(:funder) { create(:funder) }

    before do
      click_on('School configuration')
    end

    it 'allows school group to be updated' do
      select school_group.name, from: 'School group'
      click_on('Update configuration')
      school.reload
      expect(school.school_group).to eq school_group
    end

    it 'allows scoreboard to be updated' do
      select scoreboard.name, from: 'Scoreboard'
      click_on('Update configuration')
      school.reload
      expect(school.scoreboard).to eq scoreboard
    end

    it 'allows funder to be updated' do
      select funder.name, from: 'Funder'
      click_on('Update configuration')
      school.reload
      expect(school.funder).to eq funder
    end
  end

  context 'when editing data feeds' do
    let!(:weather_station) { create(:weather_station) }
    let!(:solar_pv_tuos_area) { create(:solar_pv_tuos_area) }
    let!(:dark_sky_area) { create(:dark_sky_area) }

    before do
      click_on('School configuration')
    end

    it 'allows weather station to be updated' do
      select weather_station.title, from: 'Weather Station'
      click_on('Update configuration')
      school.reload
      expect(school.weather_station).to eq weather_station
    end

    it 'allows dark sky area to be updated' do
      select dark_sky_area.title, from: 'Dark Sky Area'
      click_on('Update configuration')
      school.reload
      expect(school.dark_sky_area).to eq dark_sky_area
    end

    it 'allows solar area to be updated' do
      select solar_pv_tuos_area.title, from: 'The University of Sheffield Solar Data Feed Area'
      click_on('Update configuration')
      school.reload
      expect(school.solar_pv_tuos_area).to eq solar_pv_tuos_area
    end
  end

  context 'when editing geographic areas' do
    let!(:local_authority_area) { create(:local_authority_area) }

    before do
      click_on('School configuration')
    end

    it 'allows region to be updated' do
      select 'London', from: 'Region'
      click_on('Update configuration')
      school.reload
      expect(school.region).to eq('london')
    end

    it 'allows local authority area to be updated' do
      select local_authority_area.name, from: 'Local Authority Area'
      click_on('Update configuration')
      school.reload
      expect(school.local_authority_area).to eq(local_authority_area)
    end

    it 'allows country to be updated' do
      expect(school.country).to eq('england')
      select 'Wales', from: 'Country'
      click_on('Update configuration')
      school.reload
      expect(school.country).to eq('wales')
    end
  end

  context 'when editing project groups' do
    let!(:project_groups) { create_list(:school_group, 2, group_type: :project) }

    before do
      click_on('School configuration')
    end

    it 'displays the groups' do
      expect(page).to have_select('school_project_group_ids', options: project_groups.sort_by(&:name).map(&:name))
    end

    context 'when adding groups' do
      before do
        select(project_groups.first.name, from: 'school_project_group_ids')
        click_on 'Update configuration'
      end

      it 'has updated the association' do
        school.reload
        expect(school.project_groups).to eq([project_groups.first])
      end
    end

    context 'when there are existing editing groups' do
      before do
        school.project_groups = project_groups
        school.save
        refresh
      end

      it 'has the groups selected' do
        expect(page).to have_select('school_project_group_ids', selected: project_groups.sort_by(&:name).map(&:name))
      end

      context 'when updating the groups' do
        before do
          unselect(project_groups.first.name, from: 'school_project_group_ids')
          click_on 'Update configuration'
        end

        it 'has updated the association' do
          school.reload
          expect(school.project_groups).to eq([project_groups.last])
        end
      end
    end
  end
end
