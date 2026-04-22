# frozen_string_literal: true

module CustomSimpleForm
  class FormBuilder < SimpleForm::FormBuilder
    def input(attribute_name, options = {}, &)
      options[:wrapper] ||= resolve_wrapper(attribute_name, options)
      super
    end

    private

    def resolve_wrapper(attribute_name, options)
      as = options[:as]&.to_sym || find_input(attribute_name, options).input_type
      wrapper_bs(wrapper_key(as))
    end

    def wrapper_key(as)
      # Special case: select only has a custom wrapper in BS5
      return SimpleForm.default_wrapper if as == :select && !Current.bs5

      SimpleForm.wrapper_mappings&.fetch(as, nil) || SimpleForm.default_wrapper
    end

    def wrapper_bs(base)
      :"#{'bs4_' unless Current.bs5}#{base}"
    end
  end
end
