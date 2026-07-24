# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IssueTag do
  describe 'deletable' do
    let!(:sys_issue_tag)     { create(:issue_tag, system_id: 'sys_issue_tag') }
    let!(:non_sys_issue_tag) { create(:issue_tag, label: 'non_sys_issue_tag') }

    it 'deletes tags without a system id' do
      expect { non_sys_issue_tag.destroy }.to change(described_class, :count).by(-1)
    end

    it 'does not delete tags with a system id' do
      expect { sys_issue_tag.destroy }.not_to change(described_class, :count)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_uniqueness_of(:label) }
  end
end
