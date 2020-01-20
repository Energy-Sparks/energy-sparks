require 'rails_helper'

describe ContentBatch do

  let!(:school_1) { create(:school) }
  let!(:school_2) { create(:school) }

  it 'should continue processing if batch fails for a single school' do
    expect(AggregateSchoolService).to receive(:new).twice.and_raise(ArgumentError)
    ContentBatch.new.generate
  end


end
