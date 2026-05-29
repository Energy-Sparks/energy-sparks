# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IssuesReportMailer, :include_application_helper do
  include EmailHelpers

  let(:email) { last_email }

  before { stub_const('ENV', ENV.to_h.merge('SEND_AUTOMATED_EMAILS' => 'true', 'ENVIRONMENT_IDENTIFIER' => 'unknown')) }

  describe '#issues_report' do
    def create_issue(**)
      create(:issue, :with_tags, issue_type: :issue, status: :open, owned_by: admin, created_at: 5.days.ago,
                                 created_by: admin, review_date: 1.week.from_now, **)
    end

    def create_inactive_school_issue
      create_issue(issueable: create(:school, active: false), tag_labels: ['inactive schools'])
    end

    let(:admin) { create(:admin) }
    let(:issue) do
      create_issue(review_date: 1.day.ago, tag_labels: ['generic tag'], issueable: create(:school, :with_school_group))
    end
    let!(:issues) do
      freeze_time
      { issue:,
        note: create(:issue, issue_type: :note),
        closed_issue: create_issue(status: :closed, tag_labels: ['closed']),
        someone_elses_issue: create_issue(owned_by: create(:admin), tag_labels: ['someone else']),
        inactive_school_issue: create_inactive_school_issue }
    end
    let(:body) { email.html_part.body.raw_source }

    before do
      described_class.with(user: admin).issues_report.deliver
    end

    context 'when showing only open issues for user' do
      it {
        expect(email.subject).to eq("[energy-sparks-unknown] Energy Sparks - Issue report for #{admin.display_name}")
      }

      it { expect(body).to have_link(issue.title, href: admin_school_issue_url(issue.issueable, issue)) }
      it { expect(body).to have_text(issue.school_group.name) }
      it { expect(body).to have_text(issue.issue_tags.first.label) }
      it { expect(body).to have_text(issue.fuel_type.capitalize) }
      it { expect(body).to have_text(issue.issueable.name) }
      it { expect(body).to have_text(short_dates(issue.review_date)) }
      it { expect(body).to have_text(issue.created_by.display_name) }
      it { expect(body).to have_text(short_dates(issue.created_at)) }
      it { expect(body).to have_text(issue.updated_by.display_name) }
      it { expect(body).to have_text(short_dates(issue.updated_at)) }
      it { expect(body).to have_link('Edit', href: edit_admin_school_issue_url(issue.issueable, issue)) }

      it {
        expect(body).to have_link("View all issues for: #{admin.display_name}", href: admin_issues_url(user: admin))
      }

      it { expect(body).to have_no_text(issues[:note].title) }
      it { expect(body).to have_no_text(issues[:closed_issue].title) }
      it { expect(body).to have_no_text(issues[:someone_elses_issue].title) }
    end

    context 'when there are new issues for user' do
      let(:issues) { [create_issue(tag_labels: ['generic 2'])] }

      it { expect(body).to have_text('new!') }
    end

    context 'when there are only old issues for user' do
      let(:issues) { [create_issue(created_at: 8.days.ago, tag_labels: ['generic 3'])] }

      it { expect(body).to have_no_text('new!') }
    end

    context "when there aren't any issues for user" do
      let(:issues) { [] }

      it "doesn't send email" do
        expect(ActionMailer::Base.deliveries).to eq([])
      end
    end

    context 'with issues for inactive schools' do
      let(:issues) { [create_inactive_school_issue] }

      it "doesn't send email" do
        expect(ActionMailer::Base.deliveries).to eq([])
      end
    end

    context 'with issues not meeting the filter criteria' do
      let(:issues) do
        { overdue: create_issue(tag_labels: ['overdue'], created_at: 2.weeks.ago, review_date: Date.current),
          next_week: create_issue(tag_labels: ['next week'], created_at: 2.weeks.ago, review_date: 7.days.from_now),
          new: create_issue(tag_labels: ['new']),
          old: create_issue(tag_labels: ['old'], created_at: 2.weeks.ago, review_date: 8.days.from_now) }
      end

      it { expect(body).to have_text(issues[:overdue].title) }
      it { expect(body).to have_text(issues[:next_week].title) }
      it { expect(body).to have_text(issues[:new].title) }
      it { expect(body).to have_no_text(issues[:old].title) }
    end

    context 'with the csv report' do
      it_behaves_like 'it has a csv attachment' do
        let(:filename) { 'issues_report.csv' }
        let(:data) do
          hash = { 'Issue Type' => 'issue',
                   'Issue For' => issue.issueable.name,
                   'New' => 'New this week!',
                   'Group' => issue.school_group.name,
                   'Title' => issue.title,
                   'Tags' => 'generic tag',
                   'Fuel' => 'Gas',
                   'Next Review Date' => issue.review_date.strftime('%d/%m/%Y'),
                   'Created By' => issue.created_by.display_name,
                   'Created' => issue.created_at.strftime('%d/%m/%Y'),
                   'Updated By' => issue.updated_by.display_name,
                   'Updated' => issue.updated_at.strftime('%d/%m/%Y'),
                   'View' => "http://localhost/admin/schools/#{issue.issueable.slug}/issues/#{issue.id}",
                   'Edit' => "http://localhost/admin/schools/#{issue.issueable.slug}/issues/#{issue.id}/edit" }
          [hash.keys.join(','), hash.values.join(',')]
        end
      end
    end
  end
end
