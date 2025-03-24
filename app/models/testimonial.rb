# == Schema Information
#
# Table name: testimonials
#
#  case_study_id :bigint(8)
#  created_at    :datetime         not null
#  id            :bigint(8)        not null, primary key
#  location      :string
#  name          :string
#  quote         :text
#  role          :string
#  title         :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_testimonials_on_case_study_id  (case_study_id)
#
class Testimonial < ApplicationRecord
  translates :title, type: :string, fallbacks: { cy: :en }
  translates :quote, type: :string, fallbacks: { cy: :en }
  translates :role, type: :string, fallbacks: { cy: :en }
  translates :location, type: :string, fallbacks: { cy: :en }
end
