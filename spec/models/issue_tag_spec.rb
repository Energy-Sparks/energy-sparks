# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IssueTag do
  describe 'deletable' do
    let!(:sys_issue_tag) { create(:issue_tag, system_id: :sys_tag) }
    let!(:other_issue_tag) { create(:issue_tag) }

    it 'deletes tags without a system id' do
      other_issue_tag.destroy
      expect(described_class.count).to eq(1)
    end

    it 'does not delete tags with a system id' do
      sys_issue_tag.destroy
      expect(described_class.count).to eq(2)
    end
  end
end
