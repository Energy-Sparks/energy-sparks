# frozen_string_literal: true

require 'rails_helper'

describe 'Programme' do
  let(:school) { create(:school) }
  let(:programme_type) { create(:programme_type, bonus_score: 12) }

  let(:status) { :started }
  let(:programme) { create(:programme, programme_type:, started_on: '2020-01-01', school:, status:) }
  let(:last_observation) { programme.observations.last }

  it { expect(programme.observations.count).to eq(0) }
  it { expect(programme).not_to be_completed }
  it { expect(programme.ended_on).to be_nil }
  it { expect(programme).not_to be_abandoned }

  describe '#complete' do
    let(:current_year) { true }

    before do
      programme.complete!
    end

    context 'when programme is completed' do
      it 'marks programme as complete' do
        expect(programme).to be_completed
      end

      it 'adds ended_on date to programme' do
        expect(programme.ended_on).not_to be_nil
      end

      context 'with observation' do
        it { expect(programme.observations.count).to eq(1) }
        it { expect(last_observation.at).to eq(programme.ended_on) }
        it { expect(last_observation.school).to eq(school) }
        it { expect(last_observation.observation_type).to eq('programme') }

        it 'adds points' do
          expect(last_observation.points).to eq(12)
        end
      end
    end
  end

  describe '#abandon' do
    before do
      programme.abandon!
    end

    it 'sets status to abandoned' do
      expect(programme).to be_abandoned
    end

    it "doesn't set ended_on" do
      expect(programme.ended_on).to be_nil
    end
  end

  describe '#add_observation' do
    before do
      programme.add_observation
    end

    context 'when programme is not complete' do
      let(:status) { :started }

      it "doesn't add obervation" do
        expect(programme.observations.count).to eq(0)
      end
    end

    context 'when programme is complete' do
      let(:status) { :completed }

      it 'adds obervation' do
        expect(programme.observations.count).to eq(1)
      end

      it 'only adds one observation' do
        programme.add_observation
        expect(programme.observations.count).to eq(1)
      end
    end
  end

  describe '.recently_ended' do
    subject(:programmes) { Programme.recently_ended }

    before { freeze_time }

    let!(:ended_today) { create(:programme, ended_on: Time.zone.today) }
    let!(:ended_yesterday) { create(:programme, ended_on: 1.day.ago) }
    let!(:ended_older) { create(:programme, ended_on: 2.days.ago) }

    it 'includes programmes ended today or yesterday' do
      expect(programmes).to include(ended_today)
      expect(programmes).to include(ended_yesterday)
    end

    it "doesn't include older programmes" do
      expect(programmes).not_to include(ended_older)
    end
  end

  it_behaves_like 'a completable' do
    subject(:completable) { create(:programme, school:) }
  end
end
