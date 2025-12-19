# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardEquivalencesComponent, :include_url_helpers, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:school) { create(:school) }
  let(:user) { create(:school_admin, school: school)}

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }

  let(:params) do
    {
      id: id,
      classes: classes,
      school: school,
      user: user
    }
  end

  shared_context 'with equivalences' do
    let(:equivalence_type) { create(:equivalence_type, time_period: :last_week, meter_type: :electricity) }
    let(:equivalence_type_content) do
      create(:equivalence_type_content_version,
               equivalence_type: equivalence_type,
               equivalence_en: 'Your school spent {{gbp}} on electricity last year!',
               equivalence_cy: 'Gwariodd eich ysgol {{gbp}} ar drydan y llynedd!')
    end
    let!(:equivalence) do
      create(:equivalence,
              school: school,
              content_version: equivalence_type_content,
              data: { 'gbp' => { 'formatted_equivalence' => '£2.00' } },
              data_cy: { 'gbp' => { 'formatted_equivalence' => '£9.00' } },
              to_date: Time.zone.today)
    end
  end

  describe '#data_enabled?' do
    it { expect(component.data_enabled?).to be true }

    context 'when not data enabled' do
      let(:school) { create(:school, data_enabled: false) }

      it { expect(component.data_enabled?).to be false }

      context 'with admin and school is processing data' do
        let(:school) { create(:school, process_data: true) }
        let(:user) { create(:admin) }

        it { expect(component.data_enabled?).to be true }
      end
    end
  end

  describe '#render?' do
    context 'when not data enabled' do
      let(:school) { create(:school, data_enabled: false) }

      it { expect(component.render?).to be true }
    end

    context 'when data enabled' do
      context 'with no generated equivalences' do
        it { expect(component.render?).to be false }
      end

      context 'with equivalences' do
        include_context 'with equivalences'

        it { expect(component.render?).to be true }
      end
    end
  end

  context 'when rendering' do
    let(:html) { render_inline(described_class.new(**params)) }

    context 'when not data enabled' do
      let(:school) { create(:school, data_enabled: false) }

      it 'shows default equivalences' do
        expect(html).to have_content('the average school')
        expect(html).to have_content('How will your school compare?')
      end

      it { expect(html).not_to have_content('Your school spent £2.00 on electricity last year!') }

      it {
        expect(html).not_to have_link(I18n.t('pupils.schools.show.find_how_much_energy_used'))
      }

      it_behaves_like 'an application component' do
        let(:expected_classes) { classes }
        let(:expected_id) { id }
      end
    end

    context 'with equivalences' do
      include_context 'with equivalences'

      it { expect(html).to have_content('Your school spent £2.00 on electricity last year!') }

      it {
        expect(html).to have_link(I18n.t('pupils.analysis.explore_energy_data_html',
                                          fuel_type: I18n.t('common.electricity').downcase),
                                     href: pupils_school_analysis_path(school,
                                                                       category: equivalence_type.meter_type))
      }


      it_behaves_like 'an application component' do
        let(:expected_classes) { classes }
        let(:expected_id) { id }
      end

      it 'does not have the navigation' do
        expect(html).not_to have_css('a.carousel-control-prev')
        expect(html).not_to have_css('a.carousel-control-next')
      end

      context 'with multiple equivalences' do
        include_context 'with equivalences'

        let!(:equivalence_2) do
          create(:equivalence,
                  school: school,
                  content_version: equivalence_type_content,
                  data: { 'gbp' => { 'formatted_equivalence' => '£2.00' } },
                  data_cy: { 'gbp' => { 'formatted_equivalence' => '£9.00' } },
                  to_date: Time.zone.today)
        end

        it 'adds the navigation' do
          expect(html).to have_css('a.carousel-control-prev')
          expect(html).to have_css('a.carousel-control-next')
        end
      end
    end
  end
end
