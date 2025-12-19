# frozen_string_literal: true

require 'rails_helper'

describe Audit do
  let(:school) { create(:school) }

  context 'when no title' do
    let(:audit) { create(:audit, school:, title: '') }

    it 'fails validation' do
      expect do
        audit.save!
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it_behaves_like 'an assignable' do
    subject(:assignable) { create(:audit, school:) }
  end

  it_behaves_like 'a completable' do
    subject(:completable) { create(:audit, school:) }
  end
end
