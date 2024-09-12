require 'rails_helper'

describe 'Pupil dashboard' do
  let!(:school) { create(:school) }

  context 'when viewing equivalences' do
    context 'when school is data enabled' do
      let(:equivalence_type)          { create(:equivalence_type, time_period: :last_week, meter_type: :electricity)}
      let(:equivalence_type_content)  { create(:equivalence_type_content_version, equivalence_type: equivalence_type, equivalence_en: 'Your school spent {{gbp}} on electricity last year!', equivalence_cy: 'Gwariodd eich ysgol {{gbp}} ar drydan y llynedd!')}
      let!(:equivalence)              { create(:equivalence, school: school, content_version: equivalence_type_content, data: { 'gbp' => { 'formatted_equivalence' => '£2.00' } }, data_cy: { 'gbp' => { 'formatted_equivalence' => '£9.00' } }, to_date: Time.zone.today) }

      before do
        visit pupils_school_public_displays_equivalences_path(school, :electricity)
      end

      it 'shows equivalences' do
        expect(page).to have_content('Your school spent £2.00 on electricity last year!')
      end

      it 'shows Welsh equivalences' do
        visit pupils_school_public_displays_equivalences_path(school, :electricity, locale: 'cy')
        expect(page).to have_content('Gwariodd eich ysgol £9.00 ar drydan y llynedd')
      end
    end

    context 'when there are no equivalences for the fuel type' do
      before do
        visit pupils_school_public_displays_equivalences_path(school, :gas)
      end

      it 'displays a default equivalence' do
        expect(page).to have_content('the average school')
      end
    end

    context 'when school is not data enabled' do
      let!(:school) { create(:school, data_enabled: false) }

      before do
        visit pupils_school_public_displays_equivalences_path(school, :electricity)
      end

      it 'displays a default equivalence' do
        expect(page).to have_content('the average school')
      end
    end

    context 'when school is not public' do
      let!(:school) { create(:school, data_sharing: :within_group) }

      before do
        visit pupils_school_public_displays_equivalences_path(school, :electricity)
      end

      it 'displays a default equivalence' do
        expect(page).to have_content('the average school')
      end
    end
  end
end
