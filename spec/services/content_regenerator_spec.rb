require 'rails_helper'

describe ContentRegenerator do

  let!(:school) { create(:school) }
  let!(:logger) { double(Rails.logger) }

  before do
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
  end

  it 'should call validate and persist, aggregate and content' do
    expect_any_instance_of(Amr::ValidateAndPersistReadingsService).to receive(:perform)
    expect_any_instance_of(AggregateSchoolService).to receive(:invalidate_cache)
    expect_any_instance_of(ContentBatch).to receive(:regenerate)
    ContentRegenerator.new(school, logger).perform
  end

end
