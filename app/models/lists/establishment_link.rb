# == Schema Information
#
# Table name: lists_establishment_links
#
#  created_at              :datetime         not null
#  establishment_id        :bigint(8)        not null, primary key
#  link_established_date   :datetime
#  link_name               :string
#  link_type               :string
#  linked_establishment_id :bigint(8)        not null, primary key
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_lists_establishment_links_on_establishment_id         (establishment_id)
#  index_lists_establishment_links_on_linked_establishment_id  (linked_establishment_id)
#
module Lists
  class EstablishmentLink < ApplicationRecord
    include CsvImportable
    self.table_name = 'lists_establishment_links'

    def self.csv_name_starts_with
      'links_edubasealldata'
    end

    def self.csv_special_columns
      [['URN', 'establishment_id'], ['LinkURN', 'linked_establishment_id']]
    end

    belongs_to :establishment, class_name: 'Lists::Establishment'
    belongs_to :linked_establishment, class_name: 'Lists::Establishment'

    scope :successors, -> { where('link_type LIKE \'Successor%\'') }
  end
end
