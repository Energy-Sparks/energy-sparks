# frozen_string_literal: true

require 'rails_helper'

shared_examples 'a recently recorded interventions table' do
  it 'displays relevant interventions' do
    rows = all('tr').map { |tr| tr.all(headings).map(&:text) }
    expect(rows).to eq(expected_rows)
  end
end

describe 'Recently recorded interventions report' do
  let(:user) { create(:admin) }
  let(:other_admin) { create(:admin, name: 'other admin') }

  let(:user_school_group) { create(:school_group, default_issues_admin_user: user) }
  let(:other_admin_school_group) { create(:school_group, default_issues_admin_user: other_admin) }

  let(:user_school) { create(:school, school_group: user_school_group) }
  let(:other_admin_school) { create(:school, school_group: other_admin_school_group) }

  let!(:user_observation) { create(:observation, :intervention, school: user_school, created_at: 2.days.ago) }

  let!(:other_admin_observation) do
    create(:observation, :intervention, school: other_admin_school, created_by: create(:staff), created_at: 3.days.ago)
  end

  before do
    sign_in(user)
    visit admin_reports_path
    click_on 'Recently recorded interventions'
  end

  describe 'displaying the table' do
    let(:header) do
      ['School Group', 'Admin', 'School', 'User', 'User Role', 'User Staff Role', 'Recorded',
       'Happened', 'Intervention Type', 'Images?']
    end

    context 'without filters' do
      it_behaves_like 'a recently recorded interventions table' do
        let(:headings) { 'th, td, td' }
        let(:expected_rows) do
          [
            header,
            [user_school_group.name, user.name, user_school.name, '', '', '',
             user_observation.created_at.to_date.iso8601, user_observation.happened_on.to_date.iso8601,
             user_observation.intervention_type.name, ''],
            [other_admin_school_group.name, other_admin.name, other_admin_school.name,
             other_admin_observation.created_by.name, other_admin_observation.created_by.role.humanize,
             other_admin_observation.created_by.staff_role.title,
             other_admin_observation.created_at.to_date.iso8601,
             other_admin_observation.happened_on.to_date.iso8601,
             other_admin_observation.intervention_type.name, '']
          ]
        end
      end
    end

    context 'with filters' do
      describe 'admin filter' do
        before do
          select 'other admin', from: 'admin'
          click_on 'Filter'
        end

        it_behaves_like 'a recently recorded interventions table' do
          let(:headings) { 'th, td' }
          let(:expected_rows) do
            [
              header,
              [other_admin_school_group.name, other_admin.name, other_admin_school.name,
               other_admin_observation.created_by.name, other_admin_observation.created_by.role.humanize,
               other_admin_observation.created_by.staff_role.title,
               other_admin_observation.created_at.to_date.iso8601,
               other_admin_observation.happened_on.to_date.iso8601,
               other_admin_observation.intervention_type.name, '']
            ]
          end
        end
      end

      describe 'school group filter' do
        before do
          select user_school_group.name, from: 'school_group'
          click_on 'Filter'
        end

        it_behaves_like 'a recently recorded interventions table' do
          let(:headings) { 'th, td' }
          let(:expected_rows) do
            [
              header,
              [user_school_group.name, user.name, user_school.name, '', '', '',
               user_observation.created_at.to_date.iso8601, user_observation.happened_on.to_date.iso8601,
               user_observation.intervention_type.name, '']
            ]
          end
        end
      end

      describe 'school filter' do
        before do
          select other_admin_school.name, from: 'school'
          click_on 'Filter'
        end

        it_behaves_like 'a recently recorded interventions table' do
          let(:headings) { 'th, td' }
          let(:expected_rows) do
            [
              header,
              [other_admin_school_group.name, other_admin.name, other_admin_school.name,
               other_admin_observation.created_by.name, other_admin_observation.created_by.role.humanize,
               other_admin_observation.created_by.staff_role.title,
               other_admin_observation.created_at.to_date.iso8601,
               other_admin_observation.happened_on.to_date.iso8601,
               other_admin_observation.intervention_type.name, '']
            ]
          end
        end
      end

      describe 'user role filter' do
        before do
          select 'Staff', from: 'user_role'
          click_on 'Filter'
        end

        it_behaves_like 'a recently recorded interventions table' do
          let(:headings) { 'th, td' }
          let(:expected_rows) do
            [
              header,
              [other_admin_school_group.name, other_admin.name, other_admin_school.name,
               other_admin_observation.created_by.name, other_admin_observation.created_by.role.humanize,
               other_admin_observation.created_by.staff_role.title,
               other_admin_observation.created_at.to_date.iso8601,
               other_admin_observation.happened_on.to_date.iso8601,
               other_admin_observation.intervention_type.name, '']
            ]
          end
        end
      end
    end
  end

  describe 'csv download' do
    context 'without filters' do
      it 'allows csv download' do
        click_on 'CSV'
        expect(page.response_headers['content-type']).to eq('text/csv')
        expect(body).to \
          eq("School Group,Admin,School,User,User Role,User Staff Role,Recorded,Happened,Intervention Type,Images?\n" \
             "#{user_school_group.name},#{user.name},#{user_school.name},,,," \
             "#{user_observation.created_at.to_date.iso8601}," \
             "#{user_observation.happened_on.to_date.iso8601},#{user_observation.intervention_type.name},false\n" \
             "#{other_admin_school_group.name},#{other_admin.name},#{other_admin_school.name}," \
             "#{other_admin_observation.created_by.name},#{other_admin_observation.created_by.role.humanize}," \
             "#{other_admin_observation.created_by.staff_role.title}," \
             "#{other_admin_observation.created_at.to_date.iso8601}," \
             "#{other_admin_observation.happened_on.to_date.iso8601}," \
             "#{other_admin_observation.intervention_type.name},false\n")
      end
    end

    context 'with a filter' do
      before do
        select 'Admin', from: 'admin'
        click_on 'Filter'
      end

      it 'allows csv download' do
        click_on 'CSV'
        expect(page.response_headers['content-type']).to eq('text/csv')
        expect(body).to \
          eq("School Group,Admin,School,User,User Role,User Staff Role,Recorded,Happened,Intervention Type,Images?\n" \
             "#{user_school_group.name},#{user.name},#{user_school.name},,,," \
             "#{user_observation.created_at.to_date.iso8601}," \
             "#{user_observation.happened_on.to_date.iso8601},#{user_observation.intervention_type.name},false\n")
      end
    end
  end
end
