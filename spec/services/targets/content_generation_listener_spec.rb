require 'rails_helper'

describe Targets::ContentGenerationListener, type: :service do

  let(:school)      { create(:school) }
  let(:listener)    { Targets::ContentGenerationListener.new }

  describe '#school_content_generated' do
    context 'with a target' do
      let!(:school_target)   { create(:school_target, school: school) }

      it 'updates school target' do
        listener.school_content_generated(school)
        school_target.reload
        expect(school_target.report_last_generated).to_not be nil
        expect(school_target.report_last_generated.to_date).to eql Date.today
      end
    end

    context 'with no target' do
      it 'doesnt throw exception' do
        listener.school_content_generated(school)
      end
    end
  end

end
