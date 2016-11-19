require 'rails_helper'

describe School do
  let(:school) { create :school }
  let(:today) { Time.zone.today }

  it 'builds a slug on create using :name' do
    school = create :school
    expect(school.slug).to eq(school.name.parameterize)
  end
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

  describe '.badges_by_date' do
    it 'returns an array of badges ordered by date' do
      badge = create :badge
      badges_sash = (1..5).collect { |n| create :badges_sash, badge_id: badge.id, sash_id: school.sash_id, created_at: today.days_ago(n) }

      expect(school.badges_by_date).to eq(
        badges_sash
          .sort { |x, y| x.created_at <=> y.created_at }
          .map(&:badge)
      )
    end
  end
end
