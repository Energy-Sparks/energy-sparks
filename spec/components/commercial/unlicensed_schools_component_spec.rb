# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::UnlicensedSchoolsComponent, type: :component do
  let!(:school) do
    school = create(:school, :with_trust)
    school.update(diocese: create(:school_group, :diocese))
    school
  end

  before do
    calendar = create(:national_calendar, title: 'England and Wales')
    academic_year = create(:academic_year, calendar:)
    create(:academic_year,
           calendar:,
           start_date: academic_year.end_date + 1.day,
           end_date: academic_year.end_date + 1.year)
    render_inline described_class.new(schools: [school])
  end

  it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
    let(:table_id) { '#unlicensed-schools' }
    let(:expected_header) do
      [
        ['School Group', 'School', 'Visible?', 'Data visible?', 'Expired Licence?',
         'Licenced for Current Academic Year?', 'Licenced for Next Academic Year?', '']
      ]
    end
    let(:expected_rows) do
      [
        [school.organisation_group.name, school.name, '', '', '', 'No', 'No', 'Licences']
      ]
    end
  end
end
