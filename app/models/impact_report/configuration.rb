# frozen_string_literal: true

# == Schema Information
#
# Table name: impact_report_configurations
#
#  id              :bigint(8)        not null, primary key
#  show_engagement :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_group_id :bigint(8)        not null
#
# Indexes
#
#  index_impact_report_configurations_on_school_group_id  (school_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_group_id => school_groups.id)
#

module ImpactReport
  class Configuration < ApplicationRecord
    self.table_name = 'impact_report_configurations'

    belongs_to :school_group
  end
end
