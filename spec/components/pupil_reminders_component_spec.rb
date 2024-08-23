# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PupilRemindersComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:id) { 'custom-id'}
  let(:classes) { 'extra-classes' }
  let(:user) { create(:admin) }
  let(:school) { create(:school) }

  let(:params) do
    {
      school: school,
      user: user,
      id: id,
      classes: classes
    }
  end

  describe '#temperature_observations' do
    context 'with no observations' do
      it { expect(component.temperature_observations).to be_empty }
    end

    context 'with existing observations' do
      let!(:observation) { create(:observation, :temperature, school: school) }

      it { expect(component.temperature_observations).to eq([observation]) }
    end
  end

  describe '#show_temperature_observations?' do
    before do
      SiteSettings.create!(temperature_recording_months: %w[10 11 12])
    end

    context 'when in summer' do
      before { travel_to(Date.new(2024, 8, 1)) }

      it { expect(component.show_temperature_observations?).to be false }
    end

    context 'when in winter' do
      before { travel_to(Date.new(2024, 10, 1)) }

      it { expect(component.show_temperature_observations?).to be true }
    end
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    it { expect(html).to have_content(I18n.t('pupils.schools.show.transport_surveys')) }

    it {
      expect(html).to have_link(I18n.t('pupils.schools.show.start_transport_survey'),
                                   href: school_transport_surveys_path(school))
    }

    it { expect(html).to have_content(I18n.t('schools.prompts.programme.choose_a_new_programme_message')) }

    it {
      expect(html).to have_link(I18n.t('schools.prompts.programme.start_a_new_programme'),
                                   href: programme_types_path)
    }

    context 'when school has an active programme' do
      let!(:programme) { create(:programme, school: school) }

      it { expect(html).to have_content('You have completed') }

      it {
        expect(html).to have_link(I18n.t('common.labels.view_now'),
                                     href: programme_type_path(programme.programme_type))
      }

      it { expect(html).not_to have_selector('#new_programme') }
    end
  end
end
