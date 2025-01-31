require 'rails_helper'

describe Mailchimp::AudienceUpdater do
  subject(:service) { described_class.new }

  describe '#perform' do
    context 'when finding contacts' do
      it 'ignores pupil users'
    end

    context 'when pushing to mailchimp' do
      it 'does not add interests'
      it 'does not throw exception on error'
      it 'updates attributes on success'

      context 'when user tags need updating' do
        it 'also updates the tags'
      end
    end
  end
end
