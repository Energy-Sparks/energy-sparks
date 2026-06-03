module Navigation
  class ManageGroupComponent < BaseComponent
    attr_reader :school_group

    def initialize(school_group:, **_kwargs)
      super
      @school_group = school_group
    end
  end
end
