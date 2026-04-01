# frozen_string_literal: true

class BootstrapSwitcherFormBuilder < SimpleForm::FormBuilder
  WRAPPER_MAP = {
    boolean: :vertical_boolean,
    check_boxes: :vertical_collection,
    radio_buttons: :vertical_collection,
    file: :vertical_file,
    range: :vertical_range,
    date: :vertical_multi_select,
    datetime: :vertical_multi_select,
    time: :vertical_multi_select
  }.freeze

  def input(attribute_name, options = {}, &)
    options[:wrapper] ||= resolve_wrapper(attribute_name, options)
    super
  end

  private

  def resolve_wrapper(attribute_name, options)
    as = options[:as]&.to_sym || inferred_as(attribute_name, options)
    base = wrapper_for(as)

    namespaced_wrapper(base)
  end

  def inferred_as(attribute_name, options)
    find_input(attribute_name, options).input_type
  end

  def wrapper_for(as)
    # Special case: select only has a custom wrapper in BS5
    return :vertical_select if as == :select && Current.bs5

    WRAPPER_MAP.fetch(as, :vertical_form)
  end

  def namespaced_wrapper(base)
    :"#{'bs4_' unless Current.bs5}#{base}"
  end
end
