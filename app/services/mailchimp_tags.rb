class MailchimpTags
  def initialize(school)
    @school = school
  end

  def tags
    ret = []
    if @school.percentage_free_school_meals
      percent = @school.percentage_free_school_meals
      if percent >= 30
        ret << 'FSM30'
      elsif percent >= 25
        ret << 'FSM25'
      elsif percent >= 20
        ret << 'FSM20'
      elsif percent >= 15
        ret << 'FSM15'
      end
    end
    ret.join(',')
  end
end
