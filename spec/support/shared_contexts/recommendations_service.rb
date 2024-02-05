RSpec.shared_context 'with recommendations context' do
  let(:academic_year) { school.calendar.academic_years.last }
  let(:this_academic_year) { academic_year.start_date + 1.month }
  let(:later_this_academic_year) { academic_year.start_date + 2.months }
  let(:last_academic_year) { academic_year.start_date - 1.month }
  let(:limit) { 5 }
end
