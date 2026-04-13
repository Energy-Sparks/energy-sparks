# frozen_string_literal: true

require 'rails_helper'

describe 'Pupil Number Updates', :aggregate_failures do
  let!(:schools) do
    schools = [create(:school),
               create(:school, :with_school_group, full_school: false),
               create(:school, :with_school_group)]
    schools.last.meter_attributes.create!(attribute_type: 'floor_area_pupil_numbers', created_by: create(:admin))
    schools
  end

  before { sign_in(create(:admin)) }

  context 'when on the report index' do
    before { visit admin_reports_path }

    it 'goes to the correct page' do
      click_on 'Pupil Number Updates'
      expect(page).to have_content('Pupil Number Updates')
    end
  end

  context 'when on the report page' do
    let(:table_id) { 'table' }
    let(:expected_header) { [['School Group', 'Admin', 'School', 'Reason', '']] }

    before { visit admin_reports_pupil_number_updates_path }

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:expected_rows) do
        [['', '', schools[0].name, 'no associated DfE data', 'Attributes'],
         [schools[1].school_group.name, schools[1].default_issues_admin_user.name, schools[1].name,
          'partial school, no associated DfE data', 'Attributes'],
         [schools[2].school_group.name, schools[2].default_issues_admin_user.name, schools[2].name,
          'admin set attribute, no associated DfE data', 'Attributes']]
      end
    end

    context 'when filtering by school group' do
      before do
        select(schools[1].school_group.name, from: 'school_group')
        click_on('Filter')
      end

      it_behaves_like 'it contains the expected data table', aligned: false do
        let(:expected_rows) do
          [[schools[1].school_group.name, schools[1].default_issues_admin_user.name, schools[1].name,
            'partial school, no associated DfE data', 'Attributes']]
        end
      end
    end

    context 'when filtering by admin' do
      before do
        select(schools[1].default_issues_admin_user, from: 'admin')
        click_on('Filter')
      end

      it_behaves_like 'it contains the expected data table', aligned: false do
        let(:expected_rows) do
          [[schools[1].school_group.name, schools[1].default_issues_admin_user.name, schools[1].name,
            'partial school, no associated DfE data', 'Attributes']]
        end
      end
    end
  end
end
