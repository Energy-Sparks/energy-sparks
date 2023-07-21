require 'rails_helper'

describe Observation do
  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }

  before { SiteSettings.current.update(photo_bonus_points: 0) }

  describe '#pupil_count' do
    it "is valid when present for interventions only" do
      expect(build(:observation, observation_type: :temperature, pupil_count: 12)).to be_invalid
      expect(build(:observation, observation_type: :event, pupil_count: 12)).to be_invalid
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

    before :each do
      observation_too_old.update!(created_at: (7.days.ago - 1.minute))
      observation_last_week_1.update!(created_at: (7.days.ago + 1.minute))
      observation_last_week_2.update!(created_at: 1.minute.ago)
    end

    it 'should exclude older observations' do
      expect(Observation.recorded_in_last_week).to match_array([observation_last_week_1, observation_last_week_2])
    end
  end

  context 'creates an observation with the activities 2023 feature flag enabled' do
    context 'activities' do
      it 'sets a score if an activity has an image in its activity description and the current observation score is non zero' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          activity = create(:activity, description: "<div><figure></figure></div>")
          SiteSettings.current.update(photo_bonus_points: 15)
          observation = build(:observation, observation_type: :activity, activity: activity, points: 10)
          observation.save
          expect(observation.points).to eq(25)
        end
      end

      it 'sets a score if an activity has an image in its observation description and the current observation score is non zero' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          activity = create(:activity, description: "<div></div>")
          SiteSettings.current.update(photo_bonus_points: 15)
          observation = build(:observation, observation_type: :activity, activity: activity, description: "<div><figure></figure></div>", points: 10)
          observation.save
          expect(observation.points).to eq(25)
        end
      end

      it 'does not set a score if an activity has an image in its activity description but the current observation score is otherwise nil or zero' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          activity = create(:activity, description: "<div><figure></figure></div>")
          SiteSettings.current.update(photo_bonus_points: 15)
          observation = build(:observation, observation_type: :activity, activity: activity)
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'does not set a score if an activity has an image in its observation description but the current observation score is otherwise nil or zero' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          activity = create(:activity, description: "<div></div>")
          SiteSettings.current.update(photo_bonus_points: 15)
          observation = build(:observation, observation_type: :activity, activity: activity, description: "<div><figure></figure></div>")
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'does not sets a score if an activity has no image in its activity or observation description' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          activity = create(:activity, description: "<div></div>")
          SiteSettings.current.update(photo_bonus_points: 15)
          observation = build(:observation, observation_type: :activity, activity: activity, description: "<div></div>")
          observation.save
          expect(observation.points).to eq(nil)
        end
      end
    end

    context 'interventions' do
      let!(:intervention_type) { create(:intervention_type, score: 50) }

      before { SiteSettings.current.update(photo_bonus_points: 25) }

      it 'does not set a score if an intervention has an image in its description (bonus points) but the current observation score is otherwise nil or zero (no pupils involved)' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: false, description: "<div><figure></figure></div>")
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'does not set a score if an intervention has no pupils are involved (points) and no image in its description (bonus points)' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          SiteSettings.current.update(photo_bonus_points: 25)
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: false, description: "<div></div>")
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'only adds points automatically if its an intervention' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          observation = build(:observation, observation_type: :temperature, involved_pupils: true)
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'sets the score if pupils involved' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: true)
          observation.save
          expect(observation.points).to eq(50)
        end
      end

      it 'sets the score if pupils involved and adds bonus points if the description contains an image' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: true, description: "<div><figure></figure></div>")
          observation.save
          expect(observation.points).to eq(75)
        end
      end

      it 'does not set a score if pupils are not involved' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: false)
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'scores 0 points for previous academic years' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: true)
          observation.save
          expect(observation.points).to eq(nil)
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: false)
          observation.save
          expect(observation.points).to eq(nil)
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: false, description: "<div><figure></figure></div>")
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'updates score if date changed' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'true' do
        observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: true)
        observation.save!
        expect(observation.points).to eq(nil)
        expect(observation.intervention?).to be true
        observation.update(observation_type: :intervention, at: Time.zone.today)
        observation.reload
        expect(observation.points).to eq(50)
        end
      end
    end
  end

  context 'creates an observation with the activities 2023 feature flag disabled' do
    context 'activities' do
      it 'does not set the score if an activity has an image in its activity description' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          activity = create(:activity, description: "<div><figure></figure></div>")
          SiteSettings.current.update(photo_bonus_points: 15)
          observation = build(:observation, observation_type: :activity, activity: activity)
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'does not set a score if an activity has an image in its observation description' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          activity = create(:activity, description: "<div></div>")
          SiteSettings.current.update(photo_bonus_points: 15)
          observation = build(:observation, observation_type: :activity, activity: activity, description: "<div><figure></figure></div>")
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'does not set a score if an activity has no image in its activity or observation description' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          activity = create(:activity, description: "<div></div>")
          SiteSettings.current.update(photo_bonus_points: 15)
          observation = build(:observation, observation_type: :activity, activity: activity, description: "<div></div>")
          observation.save
          expect(observation.points).to eq(nil)
        end
      end
    end

    context 'interventions' do
      let!(:intervention_type) { create(:intervention_type, score: 50) }

      before { SiteSettings.current.update(photo_bonus_points: 25) }

      it 'does not set a score if an intervention has an image in its description' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: false, description: "<div><figure></figure></div>")
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'does not set a score if an intervention has no image in its description' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          SiteSettings.current.update(photo_bonus_points: 25)
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: false, description: "<div></div>")
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'only adds points automatically if its an intervention' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          observation = build(:observation, observation_type: :temperature, involved_pupils: true)
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'sets the score if pupils involved' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: true)
          observation.save
          expect(observation.points).to eq(50)
        end
      end

      it 'sets the score if pupils involved and the description contains an image' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: true, description: "<div><figure></figure></div>")
          observation.save
          expect(observation.points).to eq(50) # does not include photo_bonus_points
        end
      end

      it 'does not set a score if pupils not involved' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: false)
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'scores 0 points for previous academic years' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: true)
          observation.save
          expect(observation.points).to eq(nil)
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: false)
          observation.save
          expect(observation.points).to eq(nil)
        end
      end

      it 'updates score if date changed' do
        ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: 'false' do
          observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: true)
          observation.save!
          expect(observation.points).to eq(nil)
          expect(observation.intervention?).to be true
          observation.update(observation_type: :intervention, at: Time.zone.today)
          observation.reload
          expect(observation.points).to eq(50)
        end
      end
    end
  end
end
