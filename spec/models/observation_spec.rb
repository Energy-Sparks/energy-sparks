require 'rails_helper'

describe Observation do
  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }

  before { SiteSettings.current.update(photo_bonus_points: 0) }

  describe '.in_academic_year and .counts_by_academic_year' do
    let(:academic_year) { create(:academic_year, start_date: 2.days.ago, end_date: 2.days.from_now) }

    context 'when observations are on last day of academic year' do
      let!(:observations) { create_list(:observation, 2, :activity, school:, at: academic_year.end_date + 3.hours) }

      it { expect(school.observations.in_academic_year(academic_year)).to match_array(observations) }
      it { expect(school.observations.counts_by_academic_year[academic_year.id]).to be(2) }
    end

    context 'when observations are after last day of academic year' do
      let!(:observations) { create_list(:observation, 2, :activity, school:, at: academic_year.end_date + 25.hours) }

      it { expect(school.observations.in_academic_year(academic_year)).not_to match_array(observations) }
      it { expect(school.observations.counts_by_academic_year[academic_year.id]).to be_nil }
    end
  end

  describe '#pupil_count' do
    it 'is valid when present for interventions only' do
      expect(build(:observation, observation_type: :temperature, pupil_count: 12)).to be_invalid
      expect(build(:observation, observation_type: :activity, activity: create(:activity), pupil_count: 12)).to be_invalid
      expect(build(:observation, observation_type: :audit, audit: create(:audit), pupil_count: 12)).to be_invalid
      expect(build(:observation, observation_type: :school_target, school_target: create(:school_target), pupil_count: 12)).to be_invalid

      expect(build(:observation, observation_type: :intervention, intervention_type: create(:intervention_type), pupil_count: 12)).to be_valid
    end
  end

  describe '#recorded_in_last_week' do
    let(:observation_too_old)      { create(:observation, observation_type: :temperature) }
    let(:observation_last_week_1)  { create(:observation, observation_type: :temperature) }
    let(:observation_last_week_2)  { create(:observation, observation_type: :temperature) }

    before do
      observation_too_old.update!(created_at: (7.days.ago - 1.minute))
      observation_last_week_1.update!(created_at: (7.days.ago + 1.minute))
      observation_last_week_2.update!(created_at: 1.minute.ago)
    end

    it 'excludes older observations' do
      expect(Observation.recorded_in_last_week).to match_array([observation_last_week_1, observation_last_week_2])
    end
  end

  context 'creating an observation' do
    context 'activities' do
      let(:activity_type) { create(:activity_type, score: 35) }
      let(:happened_on) { }
      let(:description) { '<div></div>' }
      let!(:activity) { create(:activity, activity_type: activity_type, description: description, happened_on: happened_on) }
      let(:observation) { build(:observation, observation_type: :activity, activity:, at: happened_on) }

      before do
        SiteSettings.current.update(photo_bonus_points: 15)
        observation.save
      end

      context 'within this academic year' do
        let(:happened_on) { Time.zone.now }

        context 'without an image' do
          let(:description) { '<div></div>' }

          it 'sets the points to the activity score' do
            expect(observation.points).to eq(35)
          end
        end

        context 'with an image' do
          let(:description) { '<div><figure></figure></div>' }

          it 'sets the points to the activity score plus bonus' do
            expect(observation.points).to eq(50)
          end
        end
      end

      context 'outside academic year' do
        let(:happened_on) { 3.years.ago }

        context 'without an image' do
          let(:description) { '<div></div>' }

          it 'does not set points' do
            expect(observation.points).to be_nil
          end
        end

        context 'with an image' do
          let(:description) { '<div><figure></figure></div>' }

          it 'does not set points' do
            expect(observation.points).to be_nil
          end
        end
      end
    end

    context 'interventions' do
      let!(:intervention_type) { create(:intervention_type, score: 50) }

      before { SiteSettings.current.update(photo_bonus_points: 25) }

      it 'does not set a score if an intervention has an image in its description (bonus points) but the current observation score is otherwise nil or zero (outside academic year)' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: false) }
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, description: '<div><figure></figure></div>')
        observation.save
        expect(observation.points).to eq(nil)
      end

      it 'does not set a score if an intervention is completed outside of the academic year it was started and no image in its description (bonus points)' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: false) }
        SiteSettings.current.update(photo_bonus_points: 25)
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, description: '<div></div>')
        observation.save
        expect(observation.points).to eq(nil)
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, description: '<div></div>', points: 0)
        observation.save
        expect(observation.points).to eq(0)
      end

      it 'only adds points automatically if its an intervention' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
        observation = build(:observation, observation_type: :temperature)
        observation.save
        expect(observation.points).to eq(nil)
      end

      it 'sets the score if observation recorded within the academic year' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type)
        observation.save
        expect(observation.points).to eq(50)
      end

      it 'sets the score if observation recorded within the academic year and adds bonus points if the description contains an image' do
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, description: '<div><figure></figure></div>')
        observation.save
        expect(observation.points).to eq(75)
      end

      it 'does not set a score if observation recorded outside of the academic year' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: false) }
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type)
        observation.save
        expect(observation.points).to eq(nil)
      end

      it 'scores 0 points for previous academic years' do
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago)
        observation.save
        expect(observation.points).to eq(nil)
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago)
        observation.save
        expect(observation.points).to eq(nil)
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, description: '<div><figure></figure></div>')
        observation.save
        expect(observation.points).to eq(nil)
      end

      it 'updates score if date changed to current year' do
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago)
        observation.save!
        expect(observation.points).to eq(nil)
        expect(observation.intervention?).to be true
        observation.update(observation_type: :intervention, at: Time.zone.today)
        observation.reload
        expect(observation.points).to eq(50)
      end

      it 'does not change score if in previous year' do
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, points: 30)
        observation.save!
        expect(observation.points).to eq(30)
        observation.update(observation_type: :intervention, at: 2.years.ago, description: '<figure>')
        observation.reload
        expect(observation.points).to eq(30)
      end
    end

    context 'setting defaults' do
      context 'when the associated object is set using observable' do
        let(:transport_survey) { create(:transport_survey, school: school) }

        subject(:observation) { Observation.create(observable: transport_survey) }

        it 'sets observation_type' do
          expect(observation.observation_type).to eq('transport_survey')
        end

        it 'sets school from related object' do
          expect(observation.school).to eq(transport_survey.school)
        end
      end

      context 'when the associated object is not set with observable' do
        let(:activity) { create(:activity) }

        subject(:observation) { Observation.create(activity: activity) }

        it 'does not set observation_type' do
          expect(observation.observation_type).to be_nil
        end

        it 'does not set school' do
          expect(observation.school).to be_nil
        end

        it 'does not set at' do
          expect(observation.at).to be_nil
        end
      end
    end
  end

  describe '#update_points?' do
    let(:calendar) { create(:calendar, :with_previous_and_next_academic_years) }
    let!(:school) { create(:school, calendar:) }
    let(:current_academic_year) { calendar.current_academic_year }
    let(:previous_academic_year) { calendar.current_academic_year.previous_year }

    context 'when creating a new observation' do
      let!(:observation) { build(:observation, :activity, at: nil, school:) }

      context 'when setting at to previous academic year' do
        before do
          observation.at = previous_academic_year.start_date + 1.day
        end

        it { expect(observation.update_points?).to be(true) }
      end

      context 'when setting at to current academic year' do
        before do
          observation.at = current_academic_year.start_date + 1.day
        end

        it { expect(observation.update_points?).to be(true) }
      end

      context 'when setting at to future academic year' do
        before do
          observation.at = current_academic_year.start_date + 1.year + 1.day
        end

        it { expect(observation.update_points?).to be(true) }
      end
    end

    context 'when updating an existing observation' do
      context 'when observation is in previous academic year' do
        let!(:observation) { create(:observation, :activity, at: previous_academic_year.start_date + 1.day, school:) }

        context 'when changing to be within previous academic year' do
          before do
            observation.at = previous_academic_year.start_date + 2.days
          end

          it { expect(observation.update_points?).to be(false) }
        end

        context 'when changing to be current academic year' do
          before do
            observation.at = current_academic_year.start_date + 1.day
          end

          it { expect(observation.update_points?).to be(true) }
        end

        context 'when changing to future academic year' do
          before do
            observation.at = current_academic_year.start_date + 1.year + 1.day
          end

          it { expect(observation.update_points?).to be(true) }
        end
      end

      context 'when observation is in current academic year' do
        let!(:observation) { create(:observation, :activity, at: current_academic_year.start_date + 1.day, school:) }

        context 'when changing to be within current academic year' do
          before do
            observation.at = current_academic_year.start_date + 2.days
          end

          it { expect(observation.update_points?).to be(true) }
        end

        context 'when changing to previous academic year' do
          before do
            observation.at = previous_academic_year.start_date + 1.day
          end

          it { expect(observation.update_points?).to be(true) }
        end

        context 'when changing to future academic year' do
          before do
            observation.at = current_academic_year.start_date + 1.year + 1.day
          end

          it { expect(observation.update_points?).to be(true) }
        end
      end
    end
  end
end
