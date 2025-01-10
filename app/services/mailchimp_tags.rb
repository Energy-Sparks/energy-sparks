class MailchimpTags
  def initialize(school)
    @school = school
  end

  def tags
    tags_as_list.join(',')
  end

  def tags_as_list
    tags = []
    return tags unless @school.percentage_free_school_meals
    percent = @school.percentage_free_school_meals
    if percent >= 30
      tags << 'FSM30'
    elsif percent >= 25
      tags << 'FSM25'
    elsif percent >= 20
      tags << 'FSM20'
    elsif percent >= 15
      tags << 'FSM15'
    end
    tags
  end
end
