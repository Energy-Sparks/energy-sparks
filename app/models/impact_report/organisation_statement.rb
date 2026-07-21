# frozen_string_literal: true

# == Schema Information
#
# Table name: impact_report_organisation_statements
#
#  id                           :bigint(8)        not null, primary key
#  academic_year                :string           not null
#  actions                      :integer          default(0), not null
#  activities                   :integer          default(0), not null
#  current                      :boolean          default(FALSE), not null
#  efficiency_report_link       :string
#  primary_carbon_saving        :integer          default(0), not null
#  primary_cost_saving          :integer          default(0), not null
#  primary_saving_electricity   :integer          default(0), not null
#  primary_saving_gas           :integer          default(0), not null
#  pupils                       :integer          default(0), not null
#  schools                      :integer          default(0), not null
#  secondary_carbon_saving      :integer          default(0), not null
#  secondary_cost_saving        :integer          default(0), not null
#  secondary_saving_electricity :integer          default(0), not null
#  secondary_saving_gas         :integer          default(0), not null
#  staff                        :integer          default(0), not null
#  total_carbon_savings         :integer          default(0), not null
#  total_cost_savings           :integer          default(0), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  first_testimonial_id         :bigint(8)
#  second_testimonial_id        :bigint(8)
#
# Indexes
#
#  idx_on_first_testimonial_id_cb853f1169                        (first_testimonial_id)
#  idx_on_second_testimonial_id_b6b14d56f5                       (second_testimonial_id)
#  index_impact_report_organisation_statements_on_academic_year  (academic_year) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (first_testimonial_id => testimonials.id) ON DELETE => restrict
#  fk_rails_...  (second_testimonial_id => testimonials.id) ON DELETE => restrict
#
module ImpactReport
  class OrganisationStatement < ApplicationRecord
    self.table_name = 'impact_report_organisation_statements'

    include Deletable

    belongs_to :first_testimonial,
               optional: true,
               class_name: 'Testimonial'

    belongs_to :second_testimonial,
               optional: true,
               class_name: 'Testimonial'

    validates :academic_year, presence: true, uniqueness: true
    validates :current, uniqueness: { message: 'already exists' }, if: :current? # rubocop:disable Rails/I18nLocaleTexts

    scope :current_statement, lambda {
      where(current: true).first
    }

    def deletable?
      !current
    end

    def make_current!
      self.class.transaction do
        self.class.where.not(id: id).update_all(current: false) # rubocop:disable Rails/SkipsModelValidations
        update!(current: true)
      end
    end
  end
end
