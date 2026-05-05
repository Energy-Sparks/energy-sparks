# frozen_string_literal: true

require 'rails_helper'

describe ImpactReport::Configuration do
  context 'with valid attributes' do
    let(:config) { create(:impact_report_configuration) }

    it 'is valid' do
      expect(config).to be_valid
    end

    it 'belongs_to school_group' do
      expect(config).to belong_to(:school_group)
    end

    it 'belongs_to engagement_school' do
      expect(config).to belong_to(:engagement_school).class_name('School').optional
    end

    it 'belongs_to energy_efficiency_school' do
      expect(config).to belong_to(:energy_efficiency_school).class_name('School').optional
    end

    it 'has one attached engagement_image' do
      expect(config).to have_one_attached(:engagement_image)
    end

    it 'has one attached energy_efficiency_image' do
      expect(config).to have_one_attached(:energy_efficiency_image)
    end
  end

  describe 'default values' do
    let(:config) { create(:impact_report_configuration) }

    it 'has show_engagement default to true' do
      expect(config.show_engagement).to be true
    end

    it 'has show_energy_efficiency default to true' do
      expect(config.show_energy_efficiency).to be true
    end

    it 'has visible default to false' do
      expect(config.visible).to be false
    end
  end

  describe '#feature_visible_for?' do
    let(:school_group) { create(:school_group) }
    let(:school) { create(:school, school_group: school_group) }
    let(:config) { create(:impact_report_configuration, school_group: school_group) }

    context 'when school is nil' do
      before do
        config.update(engagement_school: nil)
      end

      it { expect(config).not_to be_feature_visible_for(:engagement) }
    end

    context 'when school is present and expiry date is blank' do
      before do
        config.update(engagement_school: school, engagement_school_expiry_date: nil)
      end

      it { expect(config.feature_visible_for?(:engagement)).to be true }
    end

    context 'when school is present and expiry date is in the future' do
      before do
        config.update(engagement_school: school, engagement_school_expiry_date: 1.year.from_now)
      end

      it { expect(config.feature_visible_for?(:engagement)).to be true }
    end

    context 'when school is present and expiry date is in the past' do
      before do
        config.update(engagement_school: school, engagement_school_expiry_date: 1.day.ago)
      end

      it { expect(config.feature_visible_for?(:engagement)).to be false }
    end

    context 'with energy_efficiency prefix' do
      before do
        config.update(energy_efficiency_school: school, energy_efficiency_school_expiry_date: 1.year.from_now)
      end

      it 'returns true' do
        expect(config.feature_visible_for?(:energy_efficiency)).to be true
      end
    end
  end

  describe '#feature_expired_for?' do
    let(:school_group) { create(:school_group) }
    let(:school) { create(:school, school_group: school_group) }
    let(:config) { create(:impact_report_configuration, school_group: school_group) }

    context 'when expiry date is blank' do
      before do
        config.update(engagement_school: school, engagement_school_expiry_date: nil)
      end

      it { expect(config.feature_expired_for?(:engagement)).to be false }
    end

    context 'when expiry date is in the future' do
      before do
        config.update(engagement_school: school, engagement_school_expiry_date: 1.year.from_now)
      end

      it { expect(config.feature_expired_for?(:engagement)).to be false }
    end

    context 'when expiry date is in the past' do
      before do
        config.update(engagement_school: school, engagement_school_expiry_date: 1.day.ago)
      end

      it { expect(config.feature_expired_for?(:engagement)).to be true }
    end
  end

  describe 'validations' do
    let(:school_group) { create(:school_group) }
    let(:school) { create(:school, school_group: school_group) }

    context 'when engagement_school is set and engagement_note is blank' do
      let(:config) do
        build(:impact_report_configuration, school_group: school_group, engagement_school: school, engagement_note: '')
      end

      it 'has an error on engagement_note' do
        expect(config).not_to be_valid
        expect(config.errors[:engagement_note]).to include("can't be blank if a featured school is selected")
      end
    end

    context 'when energy_efficiency_school is set and energy_efficiency_note is blank' do
      let(:config) do
        build(:impact_report_configuration, school_group: school_group, energy_efficiency_school: school,
                                            energy_efficiency_note: '')
      end

      it 'has an error on energy_efficiency_note' do
        expect(config).not_to be_valid
        expect(config.errors[:energy_efficiency_note]).to include("can't be blank if a featured school is selected")
      end
    end
  end

  describe 'image removal callbacks' do
    let(:school_group) { create(:school_group) }
    let(:config) { create(:impact_report_configuration, school_group: school_group) }

    context 'when engagement_image_remove is true' do
      before do
        config.engagement_image.attach(
          io: Rails.root.join('app/assets/images/pupil-carbon.jpg').open,
          filename: 'pupil-carbon.jpg'
        )
        config.update(engagement_image_remove: true)
      end

      it 'removes the engagement image' do
        expect(config.engagement_image).not_to be_attached
      end
    end

    context 'when energy_efficiency_image_remove is true' do
      before do
        config.energy_efficiency_image.attach(
          io: Rails.root.join('app/assets/images/for-multi-academies.jpg').open,
          filename: 'for-multi-academies.jpg'
        )
        config.update(energy_efficiency_image_remove: true)
      end

      it 'removes the energy efficiency image' do
        expect(config.energy_efficiency_image).not_to be_attached
      end
    end
  end
end
