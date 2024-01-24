require 'rails_helper'

describe Observation do
  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }

  before { SiteSettings.current.update(photo_bonus_points: 0) }

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

  context 'creates an observation' do
    context 'activities' do
      it 'sets a score if an activity has an image in its activity description and the current observation score is non zero' do
        activity = create(:activity, description: '<div><figure></figure></div>')
        SiteSettings.current.update(photo_bonus_points: 15)
        # Notes: see ActivityCreator where observation points are assigned for activities
        observation = build(:observation, observation_type: :activity, activity: activity, points: 10)
        observation.save
        expect(observation.points).to eq(25)
      end

      it 'sets a score if an activity has an image in its observation description and the current observation score is non zero' do
        activity = create(:activity, description: '<div></div>')
        SiteSettings.current.update(photo_bonus_points: 15)
        # Notes: see ActivityCreator where observation points are assigned for activities
        observation = build(:observation, observation_type: :activity, activity: activity, description: '<div><figure></figure></div>', points: 10)
        observation.save
        expect(observation.points).to eq(25)
      end

      it 'does not set a score if an activity has an image in its activity description but the current observation score is otherwise nil or zero' do
        activity = create(:activity, description: '<div><figure></figure></div>')
        SiteSettings.current.update(photo_bonus_points: 15)
        # Notes: see ActivityCreator where observation points are assigned for activities
        observation = build(:observation, observation_type: :activity, activity: activity, points: 0)
        observation.save
        expect(observation.points).to eq(0)
        observation = build(:observation, observation_type: :activity, activity: activity, points: nil)
        observation.save
        expect(observation.points).to eq(nil)
      end

      it 'does not set a score if an activity has an image in its observation description but the current observation score is otherwise nil or zero' do
        activity = create(:activity, description: '<div></div>')
        SiteSettings.current.update(photo_bonus_points: 15)
        observation = build(:observation, observation_type: :activity, activity: activity, description: '<div><figure></figure></div>')
        observation.save
        expect(observation.points).to eq(nil)
        observation = build(:observation, observation_type: :activity, activity: activity, description: '<div><figure></figure></div>', points: 0)
        observation.save
        expect(observation.points).to eq(0)
      end

      it 'does not sets a score if an activity has no image in its activity or observation description' do
        activity = create(:activity, description: '<div></div>')
        SiteSettings.current.update(photo_bonus_points: 15)
        observation = build(:observation, observation_type: :activity, activity: activity, description: '<div></div>')
        observation.save
        expect(observation.points).to eq(nil)
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

      it 'updates score if date changed' do
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago)
        observation.save!
        expect(observation.points).to eq(nil)
        expect(observation.intervention?).to be true
        observation.update(observation_type: :intervention, at: Time.zone.today)
        observation.reload
        expect(observation.points).to eq(50)
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
end
