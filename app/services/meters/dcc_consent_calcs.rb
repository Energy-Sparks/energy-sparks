module Meters
  class DccConsentCalcs
    def initialize(meters, dcc_consents)
      @meters = meters
      @dcc_consents = dcc_consents
    end

    def total_schools_with_consents
      consented_meters.map(&:school).uniq.count
    end

    def total_meters_with_consents
      consented_meters.count
    end

    def consented_meters
      @meters.select(&:consent_granted)
    end

    def orphan_consents
      @dcc_consents - mpans
    end

    def mpans
      @meters.map(&:mpan_mprn).map(&:to_s)
    end

    def grouped_meters
      grouped = {}
      meters_by_group = {}
      no_group = OpenStruct.new(name: 'Ungrouped')
      @meters.each do |meter|
        school_group = meter.school.school_group || no_group
        meters_by_group[school_group] ||= {}
        meters_by_group[school_group][meter.school] ||= []
        meters_by_group[school_group][meter.school] << meter
      end
      meters_by_group = meters_by_group.sort_by { |k, _v| k.name }
      meters_by_group.each { |k, v| grouped[k] = v.sort_by { |x, _y| x.name } }
      grouped
    end
  end
end
