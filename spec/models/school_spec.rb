require 'rails_helper'

describe School do

  let(:today) { Time.zone.today }
  let(:calendar) { create :calendar_with_terms, template: true }
  subject { create :school, calendar: calendar }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'builds a slug on create using :name' do
    expect(subject.slug).to eq(subject.name.parameterize)
  end

  describe 'FriendlyID#slug_candidates' do
    context 'when two schools have the same name' do
      it 'builds a different slug using :postcode and :name' do
        school = (create_list :school, 2).last
        expect(school.slug).to eq([school.postcode, school.name].join('-').parameterize)
      end
    end
    context 'when three schools have the same name and postcode' do
      it 'builds a different slug using :urn and :name' do
        school = (create_list :school, 3).last
        expect(school.slug).to eq([school.urn, school.name].join('-').parameterize)
      end
    end
  end

  describe '#meters?' do
    context 'when the school has meters of type :gas' do
      it 'returns true' do
        create :meter, school_id: subject.id
        expect(subject.meters?(:gas)).to be(true)
      end
    end
    context 'when the school has no meters' do
      it 'returns false' do
        expect(subject.meters?(:gas)).to be(false)
      end
    end
  end

  describe '#current_term' do

    it 'returns the current term' do
      current_term = create :term, calendar_id: subject.calendar_id, start_date: today.months_ago(3), end_date: today.tomorrow
      expect(subject.current_term).to eq(current_term)
    end
  end

  describe '#last_term' do

    it 'returns the term preceeding #current_term' do
      create :term, calendar_id: subject.calendar_id, start_date: today.months_ago(3), end_date: today.tomorrow
      last_term = create :term, calendar_id: subject.calendar_id, start_date: today.months_ago(6), end_date: today.yesterday.months_ago(3)

      expect(subject.last_term).to eq(last_term)
    end
  end

  describe '#badges_by_date' do
    it 'returns an array of badges ordered by date' do
      badge = create :badge
      badges_sash = (1..5).collect { |n| create :badges_sash, badge_id: badge.id, sash_id: subject.sash_id, created_at: today.days_ago(n) }

      expect(subject.badges_by_date).to eq(
        badges_sash
          .sort { |x, y| x.created_at <=> y.created_at }
          .map(&:badge)
      )
    end
  end

  describe '.top_scored' do
    let(:score) { create :score, sash_id: subject.sash_id }

    context 'when no limit is provided' do
      it 'returns an array of schools ordered by points' do
        schools = (1..5).collect { |n| create :school, :with_points, score_points: 6 - n }

        expect(School.top_scored.map(&:id)).to eq(schools.map(&:id))
      end
    end
    context 'when a limit is provided' do
      it 'returns an array of schools ordered by points of length no longer than limit' do
        schools = (1..8).collect { |n| create :school, :with_points, score_points: 8 - n }

        expect(School.top_scored(limit: 5).map(&:id)).to eq(schools[0..4].map(&:id))
      end
    end
    context 'when no date range is provided' do
      it 'limits points counted to those awarded since the start of the academic year' do
        schools = (1..5).collect { |n| create :school, :with_points, score_points: 6 - n }
        create :score_point, score_id: score.id, created_at: today.years_ago(2), num_points: 100

        expect(School.top_scored.map(&:id)).to eq(schools.map(&:id))
      end
    end
    context 'when a date range is provided' do
      it 'limits points counted to those awarded in the date range' do
        schools = (1..5).collect { |n| create :school, :with_points, score_points: 6 - n }
        create :score_point, score_id: score.id, created_at: today.years_ago(2), num_points: 100

        expect(School.top_scored(dates: today.months_ago(1)..today.tomorrow).map(&:id)).to eq(schools.map(&:id))
      end
    end
  end
end
