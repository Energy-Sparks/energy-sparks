# == Schema Information
#
# Table name: advice_page_school_benchmarks
#
#  id             :bigint           not null, primary key
#  benchmarked_as :integer          default("other_school"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  advice_page_id :bigint           not null
#  school_id      :bigint           not null
#
# Indexes
#
#  index_advice_page_school_benchmarks_on_advice_page_id  (advice_page_id)
#  index_advice_page_school_benchmarks_on_school_id       (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (advice_page_id => advice_pages.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class AdvicePageSchoolBenchmark < ApplicationRecord
  belongs_to :school, inverse_of: :advice_page_school_benchmarks
  belongs_to :advice_page, inverse_of: :advice_page_school_benchmarks
  enum :benchmarked_as, { other_school: 0, benchmark_school: 1, exemplar_school: 2 }
end
