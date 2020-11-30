class MailchimpTags
  DEFAULT_HIGH_FSM_LIMIT = 30

  def initialize(school)
    @school = school
  end

  def tags
    ret = []
    if @school.percentage_free_school_meals && (@school.percentage_free_school_meals >= high_fsm_limit)
      ret << 'High FSM'
    end
    ret.join(',')
  end

  private

  def high_fsm_limit
    ENV['HIGH_FSM_LIMIT'] ? ENV['HIGH_FSM_LIMIT'].to_i : DEFAULT_HIGH_FSM_LIMIT
  end
end
