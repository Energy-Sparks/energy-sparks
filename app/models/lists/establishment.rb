# == Schema Information
#
# Table name: lists_establishments
#
#  address3                        :string
#  administrative_ward_code        :string
#  boarders_code                   :integer
#  census_date                     :datetime
#  close_date                      :datetime
#  county_name                     :string
#  created_at                      :datetime         not null
#  diocese_code                    :string
#  district_administrative_code    :string
#  easting                         :integer
#  establishment_name              :string
#  establishment_number            :integer
#  establishment_status_code       :integer
#  establishment_type_group_code   :integer
#  federations_code                :integer
#  fsm                             :integer
#  gor_code                        :string
#  gssla_code_name                 :string
#  id                              :bigint(8)        not null, primary key
#  la_code                         :integer
#  last_changed_date               :datetime
#  locality                        :string
#  lsoa_code                       :string
#  msoa_code                       :string
#  northing                        :integer
#  number_of_pupils                :integer
#  nursery_provision_name          :string
#  official_sixth_form_code        :integer
#  open_date                       :datetime
#  parliamentary_constituency_code :string
#  percentage_fsm                  :string
#  phase_of_education_code         :integer
#  postcode                        :string
#  previous_la_code                :integer
#  school_capacity                 :integer
#  school_website                  :string
#  statutory_high_age              :integer
#  statutory_low_age               :integer
#  street                          :string
#  town                            :string
#  trusts_code                     :integer
#  type_of_establishment_code      :integer
#  ukprn                           :integer
#  updated_at                      :datetime         not null
#  uprn                            :string
#  urban_rural_code                :string
#
module Lists
  class Establishment < ApplicationRecord
    include CsvImportable

    self.table_name = 'lists_establishments'

    has_many :links, class_name: 'Lists::EstablishmentLink'
    scope :open, -> { where(close_date: nil) }

    scope :missing_diocese, -> do
      open
      .where('diocese_code LIKE ?', 'CE%') # DfE use CE prefix for Church of England
      .where.not(diocese_code: SchoolGroup.diocese.select(:dfe_code))
      .distinct
      .pluck(:diocese_code)
    end

    def self.csv_name_starts_with
      'edubasealldata'
    end

    def self.csv_special_columns
      [['URN', 'id']]
    end

    def open?
      close_date.nil?
    end

    def closed?
      !open?
    end

    # Use the links table to find this establishment's successor. Will fail if it doesn't have one
    def successor
      link = links.successors.first
      link.nil? ? nil : link.linked_establishment
    end

    # Skip through all links to get the most up-to-date establishment
    def current_establishment
      if open?
        self
      else
        s = successor # may be nil, like in the case of an establishment that has closed and not been reopened
        s.nil? ? self : s.current_establishment
      end
    end

    def self.current_establishment_from_urn(urn)
      return nil unless exists?(urn)
      est = find(urn)
      return est.current_establishment
    end

    def self.find_establishment_for_school(sch, stats)
      est = current_establishment_from_urn(sch.urn)
      unless est.nil?
        stats[:perfect] += 1
        return est
      end

      match = find_by('la_code::text || establishment_number::text = ?', sch.urn)
      if match != nil
        stats[:la_plus_en] += 1
        return match.current_establishment
      end

      puts "Warning: Couldn\'t match school with ID #{sch.id} and URN #{sch.urn} to any establishment!"
      stats[:unmatched] += 1
      return nil
    end
  end
end
