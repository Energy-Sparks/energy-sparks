# frozen_string_literal: true

class BootstrapSwitcherFormBuilder < SimpleForm::FormBuilder
  WRAPPER_MAP = {
    boolean: :vertical_boolean,
    check_boxes: :vertical_collection,
    radio_buttons: :vertical_collection,
    file: :vertical_file,
    # select: :vertical_select, # does not exist in our bs4 config, so use default (vertical_form)
    range: :vertical_range,
    date: :vertical_multi_select,
    datetime: :vertical_multi_select,
    time: :vertical_multi_select
  }.freeze

  def input(attribute_name, options = {}, &)
    options[:wrapper] = resolve_wrapper(options)
    super
  end

  private

  def resolve_wrapper(options)
    base = options[:wrapper] || WRAPPER_MAP.fetch(options[:as]&.to_sym, :vertical_form)
    namespaced(base)
  end

  def namespaced(base)
    :"#{'bs4_' unless Current.bs5}#{base}"
  end
end
