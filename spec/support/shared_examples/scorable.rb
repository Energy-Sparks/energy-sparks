RSpec.shared_examples 'a scorable' do
  describe '#scored_schools' do
    let(:activity_date) { subject.this_academic_year.end_date }
    let!(:schools) do
      (1..5).collect do |n|
        create(:school, :with_points, score_points: 6 - n, scoreboard: scoreboard, school_group: school_group,
                                      activities_happened_on: activity_date,
                                      template_calendar: subject.scorable_calendar)
      end
    end

    it 'returns schools in points order' do
      travel_to activity_date do
        expect(subject.scored_schools.map(&:sum_points)).to eq([5, 4, 3, 2, 1])
        expect(subject.scored_schools.map(&:id)).to eq(schools.map(&:id))
      end
    end

    context 'with academic years' do
      let(:activity_date) { Time.zone.today }
      let(:this_academic_year) do
        create(:academic_year, start_date: 12.months.ago, end_date: Time.zone.today, calendar: template_calendar)
      end
      let(:last_academic_year) do
        create(:academic_year, start_date: 24.months.ago, end_date: 12.months.ago, calendar: template_calendar)
      end

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
