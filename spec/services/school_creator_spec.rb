require 'rails_helper'

describe SchoolCreator, :schools, type: :service do

  describe '#process_new_school!' do
    let(:school){ create :school }
    it 'populates the default opening times' do
      service = SchoolCreator.new(school)
      service.process_new_school!
      expect(school.school_times.count).to eq(5)
      expect(school.school_times.map(&:day)).to match_array(%w{monday tuesday wednesday thursday friday})
    end
  end

end
