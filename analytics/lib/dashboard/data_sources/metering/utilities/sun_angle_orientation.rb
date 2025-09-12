  # taken from https://www.esrl.noaa.gov/gmd/grad/solcalc/calcdetails.html
  # eccentrically a direct copy of excel cell refs to avoid debugging
  # - only issues are usual ruby dodgy rational number coercion problems
  # - caused some very minor numerical disagreement with spreadsheet during the code conversion process
  class SunAngleOrientation
    attr_reader :latitude, :longitude, :time_zone_hour_offset

    # preferred access point, not instance methods, not that quick - about 5 mS on a 2019 Core i5
    def self.angle_orientation(datetime, latitude, longitude, time_zone_hour_offset = 1)
      sun = SunAngleOrientation.new(datetime, latitude, longitude, time_zone_hour_offset)
      {
        solar_elevation_degrees:  sun.solar_elevation_degrees,
        solar_azimuth_degrees:    sun.solar_azimuth_degrees
      }
    end

    def self.average_azimuth_change_degrees_per_hour(latitude, longitude)
      sol1 = angle_orientation(DateTime.new(2023, 3, 28, 6, 0), latitude, longitude)
      sol2 = angle_orientation(DateTime.new(2023, 3, 28, 7, 0), latitude, longitude)
      sol2[:solar_azimuth_degrees] - sol1[:solar_azimuth_degrees]
    end

    def initialize(datetime, latitude, longitude, time_zone_hour_offset = -1)
      @datetime = datetime
      @latitude = latitude
      @longitude = longitude
      @time_zone_hour_offset = time_zone_hour_offset
    end

    def b3
      latitude
    end

    def b4
      longitude
    end

    def b5
      time_zone_hour_offset
    end

    def date
      Date.new(@datetime.year, @datetime.month, @datetime.day)
    end

    def e2
      @e2 ||= (@datetime.hour / 24.0) + (@datetime.minute / 60.0 / 24.0)
    end
    alias_method :time_past_midnight, :e2

    def k2
      @k2 ||= 0.016708634-g2*(0.000042037+0.0000001267*g2)
    end
    alias_method :eccent_earth_orbit, :k2

    def j2
      @j2 ||= 357.52911+g2*(35999.05029 - 0.0001537*g2)
    end
    alias_method :geom_mean_anom_sun_deg, :k2

    def i2
      @i2 ||= mod(280.46646+g2*(36000.76983 + g2*0.0003032),360)
    end
    alias_method :geom_mean_long_sun_deg, :i2

    def u2
      @u2 ||= tan(radians(r2/2))*tan(radians(r2/2))
    end
    alias_method :var_y, :u2

    def v2
      @v2 ||= 4.0*degrees(u2*sin(2.0*radians(i2))-2.0*k2*sin(radians(j2))+4.0*k2*u2*sin(radians(j2))*cos(2.0*radians(i2))-0.5*u2*u2*sin(4.0*radians(i2))-1.25*k2*k2*sin(2.0*radians(j2)))
    end
    alias_method :eq_of_time, :v2

    def ab2
      @ab2 ||= mod(e2*1440+v2+4*b4-60*b5,1440)
    end
    alias_method :true_solar_time, :ab2

    def ac2
      @ac2 ||= iff(ab2/4<0,ab2/4+180,ab2/4-180)
    end
    alias_method :hour_angle_deg, :ac2

    def d2
      @d2 ||= (date - Date.new(1899,12,30)).to_f
    end
    alias_method :excel_date, :d2

    def f2
      @f2 ||= d2+2415018.5+e2-b5/24.0
    end
    alias_method :julian_day, :f2

    def i2
      @i2 ||= mod(280.46646+g2*(36000.76983 + g2*0.0003032),360)
    end
    alias_method :geom_mean_long_sun, :i2

    def g2
      @g2 ||= (f2-2451545)/36525
    end
    alias_method :julian_century, :g2

    def l2
      @l2 ||= sin(radians(j2))*(1.914602-g2*(0.004817+0.000014*g2))+sin(radians(2*j2))*(0.019993-0.000101*g2)+sin(radians(3*j2))*0.000289
    end
    alias_method :sun_eq_of_centre, :l2

    def m2
      i2 + l2
    end
    alias_method :sun_true_long_deg, :m2

    def q2
      @q2 ||= 23+(26+(21.448-g2*(46.815+g2*(0.00059-g2*0.001813)))/60)/60
    end
    alias_method :mean_obliq_ecliptic_deg, :q2

    def r2
      @r2 ||= q2+0.00256*cos(radians(125.04-1934.136*g2))
    end
    alias_method :ecliptic_corr, :r2

    def p2
      @p2 ||= m2-0.00569-0.00478*sin(radians(125.04-1934.136*g2))
    end
    alias_method :sun_app_long_deg, :p2

    def t2
      @t2 ||= degrees(asin(sin(radians(r2))*sin(radians(p2))))
    end
    alias_method :sun_decl_deg, :t2

    def ad2
      @ad2 ||= degrees(acos(sin(radians(b3))*sin(radians(t2))+cos(radians(b3))*cos(radians(t2))*cos(radians(ac2))))
    end
    alias_method :solar_zenith_angle_deg, :ad2

    def ae2
      90 - ad2
    end
    alias_method :solar_elevation_angle_deg, :ae2

    def af2
      @af2 ||= iff(ae2>85,0,iff(ae2>5,58.1/tan(radians(ae2))-0.07/power(tan(radians(ae2)),3)+0.000086/power(tan(radians(ae2)),5),iff(ae2>-0.575,1735+ae2*(-518.2+ae2*(103.4+ae2*(-12.79+ae2*0.711))),-20.772/tan(radians(ae2)))))/3600
    end
    alias_method :approx_atmospheric_refraction_deg, :af2

    def ag2
      ae2 + af2
    end
    alias_method :solar_elevation_degrees, :ag2

    def ah2
      @ah2 ||= iff(ac2>0,mod(degrees(acos(((sin(radians(b3))*cos(radians(ad2)))-sin(radians(t2)))/(cos(radians(b3))*sin(radians(ad2)))))+180,360),mod(540-degrees(acos(((sin(radians(b3))*cos(radians(ad2)))-sin(radians(t2)))/(cos(radians(b3))*sin(radians(ad2))))),360))
    end
    alias_method :solar_azimuth_degrees, :ah2

    private

    def mod(a, b)
      a.modulo(b)
    end

    def radians(d)
      d.to_f / 360.0 * 2.0 * Math::PI
    end

    def degrees(r)
      r.to_f * 360.0 / (2.0 * Math::PI)
    end

    def iff(a, b, c)
      a ? b : c
    end

    def cos(r)
      Math.cos(r)
    end

    def sin(r)
      Math.sin(r)
    end

    def asin(r)
      Math.asin(r)
    end

    def acos(r)
      Math.acos(r)
    end

    def power(a, b)
      a ** b
    end

    def tan(r)
      Math.tan(r)
    end
  end
