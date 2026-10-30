module AlertCommunityUseMixin
  def initialize(school, type = self.class.name.to_sym)
    super
    calculate_relevance
  end

  def calculate_relevance
    @relevance = (@relevance == :relevant && @school.community_usage?) ? :relevant : :never_relevant
  end

  protected def community_use
    { filter: :community_only, aggregate: :all_to_single_value }
  end
end
