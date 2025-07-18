# frozen_string_literal: true

require 'rails_helper'

describe 'Mailchimp Status Report' do
  before do
    create_list(:school_admin, 3, mailchimp_status: :subscribed, mailchimp_updated_at: 1.day.ago)
    create_list(:group_admin, 2, school_group: create(:school_group, default_issues_admin_user: nil), mailchimp_status: :unsubscribed, mailchimp_updated_at: 6.days.ago)
    create(:school_admin, mailchimp_status: :subscribed, mailchimp_updated_at: 8.days.ago)
    create(:school_admin, :skip_confirmed, confirmed_at: nil, mailchimp_status: :subscribed)
    create(:school_admin)

    sign_in(create(:admin, mailchimp_status: :cleaned))
    visit admin_reports_path
    click_on 'Mailchimp status'
    visit admin_reports_mailchimp_status_index_path
  end

  it 'displays the synchronisation status' do
    within_table('sync-status') do
      expect(all('tr').map { |tr| tr.all('td').map(&:text) }).to \
        eq([[],
            ['Pending updates', '7'],
            ['Submitted in last 24 hours', '0'],
            ['Submitted in last week', '5']])
    end
  end

  it 'displays the subscription status' do
    within_table('subscription-status') do
      expect(all('tr').map { |tr| tr.all('td').map(&:text) }).to \
        eq([[],
            %w[Archived 0],
            %w[Cleaned 1],
            %w[Nonsubscribed 0],
            %w[Subscribed 4],
            %w[Unsubscribed 2],
            %w[Unknown 1]])
    end
  end
end
