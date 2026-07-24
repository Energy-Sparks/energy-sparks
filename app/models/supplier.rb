# frozen_string_literal: true

# == Schema Information
#
# Table name: suppliers
#
#  id          :bigint(8)        not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owned_by_id :integer
#
# Indexes
#
#  index_suppliers_on_name  (name) UNIQUE
#
class Supplier < ApplicationRecord
  include Deletable

  belongs_to :owned_by, class_name: :User, optional: true

  validates :name, presence: true, uniqueness: true

  has_many :meters, dependent: :nullify
  has_many :schools, -> { distinct }, through: :meters
  has_many :issues, as: :issueable, dependent: :destroy
  has_many :active_meter_issues, -> { merge(Meter.active).distinct }, through: :meters, source: :issues

  def self.by_name
    order(:name)
  end

  # rubocop:disable Style/SafeNavigationChainLength, Metrics/AbcSize,Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_headers
      meters.from_active_schools.order(:created_at).each do |meter|
        csv << ([
          meter&.school&.school_group&.name,
          meter&.school&.school_group&.default_issues_admin_user&.name,
          meter&.school&.name,
          meter&.mpan_mprn,
          meter&.meter_type&.humanize,
          meter&.supplier&.name,
          meter&.data_source&.name,
          meter&.active,
          meter.t_meter_system,
          meter&.first_validated_reading,
          meter&.last_validated_reading,
          meter&.admin_meter_status_label,
          meter&.open_issues_count
        ] + meter&.open_issues_as_list)
      end
    end
  end

  # rubocop:enable Style/SafeNavigationChainLength, Metrics/AbcSize,Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def deletable?
    meters.active.none?
  end

  private

  def csv_headers
    ['School group', 'Admin', 'School', 'MPAN/MPRN', 'Meter type', 'Supplier', 'Data Source', 'Active', 'Half-Hourly',
     'First validated meter reading', 'Last validated meter reading', 'Admin Meter Status',
     'Open issues count', 'Open issues']
  end
end
