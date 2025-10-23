# rubocop:disable RSpec/MultipleMemoizedHelpers

RSpec.shared_examples 'a recordable' do
  before do
    SiteSettings.current.update(photo_bonus_points: 5)
  end

  subject(:recordable) { create(factory, score: 50, maximum_frequency: 3) }

  let(:calendar) { create(:calendar, :with_previous_and_next_academic_years) }
  let(:current_academic_year_date) { calendar.current_academic_year.start_date + 1.day}
  let(:previous_academic_year_date) { calendar.current_academic_year.previous_year.start_date + 1.day }
  let(:future_academic_year_date) { calendar.current_academic_year.next_year.start_date + 1.day }

  let(:school) { create(:school, calendar:) }

  def create_recordings(count, date, description: description_without_image)
    create_list(recorded_factory, count, trait, {
      school:,
      description:,
      recording_date_field => date,
      recordable.class.model_name.param_key => recordable
    })
  end

  shared_examples 'an observation with points' do |points: 50, bonus_points: 0|
    it "records a score#{' and bonus points' if bonus_points > 0}" do
      expect(recording.reload.points).to eq(points + bonus_points)
    end
  end

  shared_examples 'an observation with nil points' do
    it 'has not recorded a score yet' do
      expect(recording.reload.points).to eq(nil)
    end
  end

  shared_examples 'an observation with zero points' do
    it 'records a zero score' do
      expect(recording.reload.points).to eq(0)
    end
  end


  let(:description_with_image) { '<div><figure><img src="image1.jpg"/></figure></div>' }
  let(:description_without_image) { '<div>No images here</div>' }

  context 'when creating a new recording' do
    let(:recording) do
      build(recorded_factory, trait,
        school:,
        description: description_without_image,
        recording_date_field => recording_date,
        recordable.class.model_name.param_key => recordable)
    end

    context 'when recording date is in current academic year' do
      let(:recording_date) { current_academic_year_date }

      context 'when no other recordings in the current academic year' do
        before { Tasks::Recorder.new(recording, nil).process }

        it_behaves_like 'an observation with points', points: 50
      end

      context 'with less than maximum_frequency recordings in the same year' do
        before do
          create_recordings(1, current_academic_year_date)
          Tasks::Recorder.new(recording, nil).process
        end

        it_behaves_like 'an observation with points', points: 50
      end

      context 'with maximum_frequency recordings in the same year' do
        before do
          create_recordings(3, current_academic_year_date)
          Tasks::Recorder.new(recording, nil).process
        end

        it_behaves_like 'an observation with zero points'
      end

      context 'with maximum_frequency recordings in a previous academic year' do
        before do
          create_recordings(3, previous_academic_year_date)
          Tasks::Recorder.new(recording, nil).process
        end

        it_behaves_like 'an observation with points', points: 50
      end

      context 'with maximum_frequency recordings in a future academic year' do
        before do
          create_recordings(3, future_academic_year_date)
          Tasks::Recorder.new(recording, nil).process
        end

        it_behaves_like 'an observation with points', points: 50
      end

      context 'with description including image' do
        before do
          recording.description = description_with_image
          Tasks::Recorder.new(recording, nil).process
        end

        it_behaves_like 'an observation with points', points: 50, bonus_points: 5
      end
    end

    context 'when recording is in an previous academic year' do
      let(:recording_date) { previous_academic_year_date }

      before { Tasks::Recorder.new(recording, nil).process }

      it_behaves_like 'an observation with zero points'
    end

    context 'when recording is in a future academic year' do
      let(:recording_date) { future_academic_year_date }

      context 'with no other recordings in the same year' do
        before { Tasks::Recorder.new(recording, nil).process }

        it_behaves_like 'an observation with points', points: 50
      end

      context 'with maximum_frequency recordings in the same year' do
        before do
          create_recordings(3, future_academic_year_date)
          Tasks::Recorder.new(recording, nil).process
        end

        it_behaves_like 'an observation with zero points'
      end
    end
  end

  context 'when updating an existing recording' do
    context 'with less than maximum_frequency recordings in the current academic year' do
      let!(:recordings) { create_recordings(2, current_academic_year_date) }
      let(:recording) { recordings.first.reload }

      it_behaves_like 'an observation with points', points: 50

      context 'when figure is added to description' do
        before { recording.update!(description: description_with_image) }

        it_behaves_like 'an observation with points', points: 50, bonus_points: 5
      end
    end

    context 'with maximum_frequency recordings in the current academic year' do
      let!(:recordings) { create_recordings(3, current_academic_year_date) }
      let(:recording) { recordings.first.reload }

      it_behaves_like 'an observation with points', points: 50

      context 'when figure is added to description' do
        before { recording.update!(description: description_with_image) }

        it_behaves_like 'an observation with points', points: 50, bonus_points: 5
      end
    end

    context 'with more than maximum_frequency recordings in the current academic year' do
      let!(:recordings) { create_recordings(4, current_academic_year_date) }

      context 'with a recording with no points' do
        let(:recording) { recordings.last.reload }

        it_behaves_like 'an observation with zero points'

        context 'when figure is added to description' do
          before { recording.update!(description: description_with_image) }

          it_behaves_like 'an observation with zero points'
        end

        context 'when moving to a future academic year' do
          before { recording.update!(recording_date_field => future_academic_year_date) }

          it_behaves_like 'an observation with points', points: 50
        end
      end

      context 'with a recording with points' do
        let(:recording) { recordings.first.reload }

        it_behaves_like 'an observation with points', points: 50

        context 'when figure is added to description' do
          before { recording.update!(description: description_with_image) }

          it_behaves_like 'an observation with points', points: 50, bonus_points: 5
        end
      end
    end

    context 'with maximum_frequency recordings in a future academic year' do
      let!(:recordings) { create_recordings(3, future_academic_year_date) }

      context 'with a recording in current year with points' do
        let!(:recording) { create_recordings(1, current_academic_year_date, description: description_with_image).first }

        it_behaves_like 'an observation with points', points: 55

        context 'when moving to the same future academic year' do
          before { recording.update!(recording_date_field => future_academic_year_date) }

          it_behaves_like 'an observation with zero points'
        end
      end
    end

    context 'with more than maximum_frequency recordings in a previous academic year' do
      let!(:recordings) { create_recordings(4, previous_academic_year_date) }

      it 'points are all zero' do
        recordings.each do |recording|
          expect(recording.points.to_i).to eq(0)
        end
      end

      context 'when updating all recording descriptions' do
        before do
          recordings.each do |recording|
            recording.update!(description: description_with_image)
          end
        end

        it 'does not update points' do
          recordings.each do |recording|
            expect(recording.points.to_i).to eq(0)
          end
        end
      end

      context 'when updating year to this year' do
        let(:recording) { recordings.last.reload }

        before do
          recording.update!(recording_date_field => current_academic_year_date)
        end

        it_behaves_like 'an observation with points', points: 50
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
