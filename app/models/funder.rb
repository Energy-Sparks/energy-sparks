# == Schema Information
#
# Table name: funders
#
#  id   :bigint(8)        not null, primary key
#  name :string           not null
#
class Funder < ApplicationRecord
  has_many :schools
  has_many :school_groups

  scope :with_schools,  -> { where('id IN (SELECT DISTINCT(funder_id) FROM schools UNION SELECT DISTINCT(funder_id) FROM school_groups)') }
  scope :by_name,       -> { order(name: :asc) }

  validates :name, presence: true, uniqueness: true

  # Return counts of visible schools by funder
  #
  # Schools are either associated directly with a funder or indirectly via
  # their school group. Uses a subquery to identify the schools for each
  # funder then groups and counts them.
  #
  # Returns funders without any funded schools, but not schools without
  # any source of funding. See Schools.unfunded.
  def self.funded_school_counts(visible: true, data_enabled: true)
    query = <<-SQL.squish
      SELECT funders.name, count(funded_schools.id)
      FROM funders LEFT JOIN (
        SELECT funders.id AS funder_id, schools.id AS id
        FROM
         schools, funders
        WHERE
         schools.funder_id = funders.id AND
         schools.visible = $1 AND
         schools.data_enabled = $2
        UNION
        SELECT funders.id AS funder_id, schools.id AS id
        FROM
         schools, school_groups, funders
        WHERE
         school_groups.funder_id = funders.id AND
         schools.school_group_id = school_groups.id AND
         schools.funder_id is null AND
         schools.visible = $1 AND
         schools.data_enabled = $2
       ) AS funded_schools ON funders.id = funded_schools.funder_id
      GROUP BY funders.name
      ORDER BY funders.name;
    SQL
    sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
    Funder.connection.select_all(sanitized_query, '', [visible, data_enabled]).rows.map do |row|
      [row[0], row[1]]
    end.to_h
  end
end
