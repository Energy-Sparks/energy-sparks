module SchoolGroupsHelper
  #Accepts a list of savings as produced by SchoolGroups::PriorityActions
  #OpenStruct(school:, average_one_year_saving_gbp, :one_year_saving_co2)
  #
  #Sorts them by school name
  def sort_priority_actions(list_of_savings)
    list_of_savings.sort {|a, b| a.school.name <=> b.school.name }
  end
end
