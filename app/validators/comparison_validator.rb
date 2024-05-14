## From Rails 7, can be removed when we upgrade

class ComparisonValidator < ActiveModel::EachValidator # :nodoc:
  COMPARE_CHECKS = { greater_than: :>, greater_than_or_equal_to: :>=,
    equal_to: :==, less_than: :<, less_than_or_equal_to: :<=,
    other_than: :!= }.freeze

  def error_options(value, option_value)
    options.except(*COMPARE_CHECKS.keys).merge!(
      count: option_value,
      value: value
    )
  end

  def check_validity!
    unless options.keys.intersection(COMPARE_CHECKS.keys).any?
      raise ArgumentError, 'Expected one of :greater_than, :greater_than_or_equal_to, '\
      ':equal_to, :less_than, :less_than_or_equal_to, or :other_than option to be supplied.'
    end
  end

  def validate_each(record, attr_name, value)
    options.slice(*COMPARE_CHECKS.keys).each do |option, raw_option_value|
      option_value = resolve_value(record, raw_option_value)

      if value.nil? || value.blank?
        return record.errors.add(attr_name, :blank, **error_options(value, option_value))
      end

      unless value.public_send(COMPARE_CHECKS[option], option_value)
        record.errors.add(attr_name, option, **error_options(value, option_value))
      end
    rescue ArgumentError => e
      record.errors.add(attr_name, e.message)
    end
  end

  def resolve_value(record, value)
    case value
    when Proc
      if value.arity == 0
        value.call
      else
        value.call(record)
      end
    when Symbol
      record.send(value)
    else
      if value.respond_to?(:call)
        value.call(record)
      else
        value
      end
    end
  end
end
