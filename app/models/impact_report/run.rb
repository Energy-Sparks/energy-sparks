# frozen_string_literal: true

# == Schema Information
#
# Table name: impact_report_runs
#
#  id              :bigint(8)        not null, primary key
#  run_date        :date             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_group_id :bigint(8)        not null
#
# Indexes
#
#  index_impact_report_runs_on_school_group_id  (school_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_group_id => school_groups.id)
#

module ImpactReport
  class Run < ApplicationRecord
    self.table_name = 'impact_report_runs'

    belongs_to :school_group
    has_many :metrics, class_name: 'ImpactReport::Metric', inverse_of: :impact_report_run, dependent: :destroy
  end
end
