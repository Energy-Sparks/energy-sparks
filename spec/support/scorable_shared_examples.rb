RSpec.shared_examples 'a scorable' do
  describe '#scored_schools' do
    let!(:schools) { (1..5).collect { |n| create :school, :with_points, score_points: 6 - n, scoreboard: scoreboard, school_group: school_group, activities_happened_on: 6.months.ago, template_calendar: subject.scorable_calendar } }

    it 'returns schools in points order' do
      expect(subject.scored_schools.map(&:id)).to eq(schools.map(&:id))
    end

    context 'with academic years' do
      let(:this_academic_year) { create(:academic_year, start_date: 12.months.ago, end_date: Time.zone.today, calendar: template_calendar) }
      let(:last_academic_year) { create(:academic_year, start_date: 24.months.ago, end_date: 12.months.ago, calendar: template_calendar) }

      it 'accepts an academic year and restricts' do
        expect(subject.scored_schools(academic_year: this_academic_year).map(&:sum_points).any?(&:zero?)).to eq(false)
        expect(subject.scored_schools(academic_year: last_academic_year).map(&:sum_points).all?(&:nil?)).to eq(true)
      end

      it 'also defaults to the current academic year' do
        create :school, :with_points, score_points: 6, school_group: school_group, scoreboard: scoreboard, activities_happened_on: 18.months.ago
        expect(subject.scored_schools(academic_year: last_academic_year).to_a.size).to be 6
        expect(subject.scored_schools(academic_year: this_academic_year).to_a.size).to be 6
        expect(subject.scored_schools.to_a.size).to be 6
      end
    end
  end

  describe '#this_academic_year' do
    it 'finds the right year' do
      expect(subject.this_academic_year).to eq subject.scorable_calendar.academic_year_for(Time.zone.today)
    end
  end

  describe '#previous_academic_year' do
    let!(:previous_year) { create(:academic_year, calendar: subject.scorable_calendar, start_date: AcademicYear.first.start_date.prev_year, end_date: AcademicYear.first.start_date.prev_day) }

    it 'finds the right year' do
      expect(subject.previous_academic_year).to eq subject.scorable_calendar.academic_year_for(Time.zone.today).previous_year
    end
  end
end
