RSpec.shared_examples 'a recordable' do
  shared_context 'with updated description' do |text = 'updated with figure'|
    before { recording.update!(description: text) }
  end

  before do
    SiteSettings.current.update(photo_bonus_points: 5)
  end

  subject(:recordable) { create(factory, score: 50, maximum_frequency: 5) }

  let(:school) { create(:school) }
  let(:recording_date) { Time.zone.today }

  def create_recordings(count, date)
    create_list(recorded_factory, count, trait, {
      school:,
      recording_date_field => date,
      recordable.class.model_name.param_key => recordable
    })
  end

  context 'when creating a new recording' do
    let(:recording) do
      build(recorded_factory, trait,
        school:,
        recording_date_field => recording_date,
        recordable.class.model_name.param_key => recordable)
    end

    context 'when no other recordings exist' do
      before { Tasks::Recorder.new(recording, nil).process }

      it 'records a score' do
        expect(recording.reload.points).to eq(50)
      end
    end

    context 'with one other recording this academic year' do
      before do
        create_recordings(1, Time.zone.today)
        Tasks::Recorder.new(recording, nil).process
      end

      context 'when there are less than the threshold' do
        it 'records a score' do
          expect(recording.reload.points).to eq(50)
        end
      end
    end

    context 'with previous recordings up to threshold' do
      before do
        create_recordings(5, Time.zone.today)
        Tasks::Recorder.new(recording, nil).process
      end

      it 'does not record a score' do
        expect(recording.reload.points.to_i).to eq(0)
      end
    end

    context 'with the previous recordings in earlier academic years' do
      before do
        create_recordings(5, Time.zone.today - 1.year)
        Tasks::Recorder.new(recording, nil).process
      end

      it 'returns a score' do
        expect(recording.reload.points).to eq(50)
      end
    end

    context 'when recording is in an earlier academic year' do
      let(:recording_date) { Time.zone.today - 1.year }

      before { Tasks::Recorder.new(recording, nil).process }

      it 'does not record a score' do
        expect(recording.reload.points.to_i).to eq(0)
      end
    end
  end

  context 'when updating an existing recording' do
    context 'when there is one recording this year' do
      let!(:recordings) { create_recordings(1, Time.zone.today) }
      let(:recording) { recordings.first.reload }

      it { expect(recording.points).to eq(50) }

      context 'when figure is added to description' do
        include_context 'with updated description', 'updated with figure'

        it 'updates score with bonus' do
          expect(recording.points).to eq(55)
        end
      end
    end

    context 'when there are recordings at the threshold' do
      let!(:recordings) { create_recordings(5, Time.zone.today) }
      let(:recording) { recordings.first.reload }

      it { expect(recording.points).to eq(50) }

      context 'when figure is added to description' do
        include_context 'with updated description', 'updated with figure'

        it 'updates score with bonus' do
          expect(recording.points).to eq(55)
        end
      end
    end

    context 'when there are recordings over the threshold' do
      let!(:recordings) { create_recordings(6, Time.zone.today) }

      context 'when updating non points recording' do
        let(:recording) { recordings.last.reload }

        it { expect(recording.points.to_i).to eq(0) }

        context 'when figure is added to description' do
          include_context 'with updated description', 'updated with figure'

          it 'updates score with bonus' do
            expect(recording.points.to_i).to eq(0)
          end
        end
      end

      context 'when updating a recording with points' do
        let(:recording) { recordings.first.reload }

        it { expect(recording.points).to eq(50) }

        context 'when figure is added to description' do
          include_context 'with updated description', 'updated with figure'

          it 'updates score with bonus' do
            expect(recording.points).to eq(55)
          end
        end
      end
    end

    context 'when there are recordings over the threshold for a previous year' do
      let!(:recordings) { create_recordings(6, Time.zone.today - 1.year) }

      it 'points are all zero' do
        recordings.each do |recording|
          expect(recording.points.to_i).to eq(0)
        end
      end

      context 'when updating all recording descriptions' do
        before do
          recordings.each do |recording|
            recording.update!(description: 'updated with figure')
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
          recording.update!(recording_date_field => Time.zone.today)
        end

        it 'updates score' do
          expect(recording.points).to eq(50)
        end
      end
    end
  end
end
