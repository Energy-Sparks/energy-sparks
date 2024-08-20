# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PupilRemindersComponent, :include_application_helper, type: :component do
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

    it 'displays the default prompts' do
      within('#custom-id') do
        expect(html).to have_css('#transport_surveys')
        expect(html).to have_css('#new_programme')
        expect(html).to have_css('#choose_activity')
      end
    end
  end
end
