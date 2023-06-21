module SchoolGroups
  class ComparisonsCsvGenerator
    def initialize(school_group:, advice_page_keys: [])
      @school_group = school_group
      @advice_page_keys = advice_page_keys
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
      end
    end

    private


    def headers
      []
    end
  end
end
