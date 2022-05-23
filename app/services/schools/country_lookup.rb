module Schools
  class CountryLookup
    def initialize(school)
      @school = school
    end

    def country
      scotland_postcodes = %w[AB DD DG EH FK G HS IV KA KW KY ML PA PH TD ZE]
      wales_postcodes    = %w[CF CH GL HR LD LL NP SA SY]
      postcode_prefix = @school.postcode.upcase[/^[[:alpha:]]+/]

      return :scotland if scotland_postcodes.include?(postcode_prefix)

      if wales_postcodes.include?(postcode_prefix)
        if postcode_prefix == 'SY'
          return @school.postcode.upcase[/[[:digit:]]+/].to_i < 15 ? :england : :wales
        else
          return :wales
        end
      end

      :england
    end
  end
end
