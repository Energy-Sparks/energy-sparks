RSpec.shared_examples 'a recordable' do
  subject(:recordable) { create(factory, score: 50, maximum_frequency: 5) }

  let(:school) { create(:school) }
  let(:academic_year) { create(:academic_year)}

  context 'when recording in current year' do
    context 'with no previous recordings' do
      it 'returns a score' do
        allow(school).to receive(:academic_year_for).and_return(academic_year)
        expect(recordable.score_when_recorded_at(school, Time.zone.today)).to eq(50)
      end
    end

    context 'with previous recordings this academic year' do
      let(:existing) { 1 }

      before do
        create_list(recorded_factory, existing, trait, {
          school: school,
          recording_date_field => Time.zone.today,
          recordable.class.model_name.param_key => recordable
        })
      end

      context 'when there are less than the threshold' do
        it 'returns a score' do
          allow(school).to receive(:academic_year_for).and_return(academic_year)
          expect(recordable.score_when_recorded_at(school, Time.zone.today)).to eq(50)
        end
      end

      context 'when there are more than the threshold' do
        let(:existing) { 5 }

        it 'returns no score' do
          allow(school).to receive(:academic_year_for).and_return(academic_year)
          expect(recordable.score_when_recorded_at(school, Time.zone.today)).to eq(nil)
        end
      end
    end

    context 'with the previous recordings are in earlier academic years' do
      let(:existing) { 5 }

      before do
        allow(school).to receive(:academic_year_for).and_return(academic_year)
        create_list(recorded_factory, existing, trait, {
          school: school,
          recording_date_field => academic_year.start_date - 1,
          recordable.class.model_name.param_key => recordable
        })
      end

      it 'returns a score' do
        expect(recordable.score_when_recorded_at(school, Time.zone.today)).to eq(50)
      end
    end
  end

  context 'when recordings are in earlier academic years' do
    let(:academic_year) { create(:academic_year, start_date: 12.months.ago, end_date: 6.months.ago)}

    it 'returns no score' do
      allow(school).to receive(:academic_year_for).and_return(academic_year)
      expect(recordable.score_when_recorded_at(school, Time.zone.today)).to eq(nil)
    end
  end
end
