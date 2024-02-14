# Custom active record type that allows for a variety of different
# values to be serialised into a string column in the database.
#
# This is currently used to support storing the results of a
# variety of different calculations (which may be a number, string,
# date, etc) in a single column.
#
# Handles serialising and deserialising dates (but not datetimes)
# As well as Float::NAN and Float::Infinity values which can be
# produced by our analysis code.
#
# For other values it relies on the existing AR support for
# serialising ruby types to and from JSON.
class DynamicType < ActiveModel::Type::Value
  ISO_DATE = /\A(\d{4})-(\d\d)-(\d\d)\z/

  def type
    :dynamic_type
  end

  # Serialize to a string for storing in the database
  def serialize(value)
    # These values are consistent with how YAML.dump serialises
    # Float::NAN and Float::INFINITE values
    return '.nan' if needs_conversion?(value) && value.nan?
    return '.inf' if needs_conversion?(value) && value.infinite? == 1
    return '-.Inf' if needs_conversion?(value) && value.infinite? == -1
    # Dates, booleans, etc will use AR serialisation, e.g
    # boolean becomes 't'/'f', Dates are ISO 8601 serialised
    return value unless value.is_a?(::String)
    ActiveSupport::JSON.encode(value) rescue nil
  end

  # Deserialize from a string as a appropriate Ruby type
  #
  # Has to handle both our custom mapping for Float::NAN and
  # Float::INFINITY as well as the default mapping of dates
  # and booleans to formatted strings
  def deserialize(value)
    return value unless value.is_a?(::String)

    # As used by ActiveRecord::Type::Date
    # String will be known format so can use this which is
    # faster than Date.parse
    if value =~ ISO_DATE
      return Date.new($1.to_i, $2.to_i, $3.to_i)
    end
    case value
    when 't'
      true
    when 'f'
      false
    when '.nan'
      Float::NAN
    when '.inf'
      Float::INFINITY
    when '-.Inf'
      -Float::INFINITY
    else
      # Both a fallback but also handles turns floats and integers
      # into native types
      ActiveSupport::JSON.decode(value) unless value.nil?
    end
  end

  # Has the value been modified since it was read?
  # Taken from ActiveRecord::Type::Json
  def changed_in_place?(raw_old_value, new_value)
    deserialize(raw_old_value) != new_value
  end

  private

  def needs_conversion?(value)
    value.is_a?(Float) || value.is_a?(BigDecimal)
  end

end

ActiveRecord::Type.register(:dynamic_type, DynamicType)
