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

  def self.school_counts
    query = <<-SQL.squish
      select funders.name, count(x.id) from funders LEFT JOIN (
       select funders.id as funder_id, schools.id as id from schools, school_groups, funders
       where school_groups.funder_id = funders.id and schools.school_group_id = school_groups.id
       union all
       select funders.id as funder_id, schools.id as id from schools, funders
       where schools.funder_id = funders.id
       ) as x ON funders.id = x.funder_id
      group by funders.name
      order by funders.name;
    SQL
    sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
    Funder.connection.select_all(sanitized_query).rows.map do |row|
      OpenStruct.new(name: row[0], school_count: row[1])
    end
  end
end
