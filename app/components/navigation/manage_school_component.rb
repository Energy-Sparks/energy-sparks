module Navigation
  class ManageSchoolComponent < BaseComponent
    attr_reader :school

    def initialize(school:, **_kwargs)
      super
      @school = school
    end
  end
end
