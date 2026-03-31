# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ModuleLength

module SimpleFormBootstrap4
  def self.apply(config)
    # vertical forms
    #
    # vertical default_wrapper
    config.wrappers :bs4_vertical_form, tag: 'div', class: 'form-group',
                                        error_class: 'form-group-invalid',
                                        valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :pattern
      b.optional :min_max
      b.optional :readonly
      b.use :label, class: 'form-control-label'
      b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical input for boolean
    config.wrappers :bs4_vertical_boolean, tag: 'fieldset', class: 'form-group', error_class: 'form-group-invalid',
                                           valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :form_check_wrapper, tag: 'div', class: 'form-check' do |bb|
        bb.use :input, class: 'form-check-input', error_class: 'is-invalid'
        bb.use :label, class: 'form-check-label'
        bb.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
        bb.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # vertical input for radio buttons and check boxes
    config.wrappers :bs4_vertical_collection, item_wrapper_class: 'form-check', tag: 'fieldset', class: 'form-group',
                                              error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
        ba.use :label_text
      end
      b.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical input for inline radio buttons and check boxes
    config.wrappers :bs4_vertical_collection_inline,
                    item_wrapper_class: 'form-check form-check-inline',
                    tag: 'fieldset', class: 'form-group',
                    error_class: 'form-group-invalid',
                    valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
        ba.use :label_text
      end
      b.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical file input
    config.wrappers :bs4_vertical_file, tag: 'div', class: 'form-group', error_class: 'form-group-invalid',
                                        valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :readonly
      b.use :label
      b.use :input, class: 'form-control-file', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical multi select
    config.wrappers :bs4_vertical_multi_select, tag: 'div', class: 'form-group', error_class: 'form-group-invalid',
                                                valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label, class: 'form-control-label'
      b.wrapper tag: 'div', class: 'd-flex flex-row justify-content-between align-items-center' do |ba|
        ba.use :input, class: 'form-control mx-1', error_class: 'is-invalid', valid_class: 'is-valid'
      end
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # vertical range input
    config.wrappers :bs4_vertical_range, tag: 'div', class: 'form-group', error_class: 'form-group-invalid',
                                         valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :readonly
      b.optional :step
      b.use :label
      b.use :input, class: 'form-control-range', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # horizontal forms
    #
    # horizontal default_wrapper
    config.wrappers :bs4_horizontal_form, tag: 'div', class: 'form-group row', error_class: 'form-group-invalid',
                                          valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :pattern
      b.optional :min_max
      b.optional :readonly
      b.use :label, class: 'col-sm-3 col-form-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal input for boolean
    config.wrappers :bs4_horizontal_boolean, tag: 'div', class: 'form-group row', error_class: 'form-group-invalid',
                                             valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper tag: 'label', class: 'col-sm-3' do |ba|
        ba.use :label_text
      end
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |wr|
        wr.wrapper :form_check_wrapper, tag: 'div', class: 'form-check' do |bb|
          bb.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
          bb.use :label, class: 'form-check-label'
          bb.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
          bb.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
        end
      end
    end

    # horizontal input for radio buttons and check boxes
    config.wrappers :bs4_horizontal_collection, item_wrapper_class: 'form-check', tag: 'div',
                                                class: 'form-group row',
                                                error_class: 'form-group-invalid',
                                                valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label, class: 'col-sm-3 form-control-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal input for inline radio buttons and check boxes
    config.wrappers :bs4_horizontal_collection_inline,
                    item_wrapper_class: 'form-check form-check-inline', tag: 'div',
                    class: 'form-group row',
                    error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label, class: 'col-sm-3 form-control-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal file input
    config.wrappers :bs4_horizontal_file, tag: 'div', class: 'form-group row', error_class: 'form-group-invalid',
                                          valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :readonly
      b.use :label, class: 'col-sm-3 form-control-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal multi select
    config.wrappers :bs4_horizontal_multi_select, tag: 'div', class: 'form-group row',
                                                  error_class: 'form-group-invalid',
                                                  valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label, class: 'col-sm-3 control-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.wrapper tag: 'div', class: 'd-flex flex-row justify-content-between align-items-center' do |bb|
          bb.use :input, class: 'form-control mx-1', error_class: 'is-invalid', valid_class: 'is-valid'
        end
        ba.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # horizontal range input
    config.wrappers :bs4_horizontal_range, tag: 'div', class: 'form-group row', error_class: 'form-group-invalid',
                                           valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :readonly
      b.optional :step
      b.use :label, class: 'col-sm-3 form-control-label'
      b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, class: 'form-control-range', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # inline forms
    #
    # inline default_wrapper
    config.wrappers :bs4_inline_form, tag: 'span', error_class: 'form-group-invalid',
                                      valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :pattern
      b.optional :min_max
      b.optional :readonly
      b.use :label, class: 'sr-only'

      b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.optional :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # inline input for boolean
    config.wrappers :bs4_inline_boolean, tag: 'span', class: 'form-check flex-wrap justify-content-start mr-sm-2',
                                         error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :label, class: 'form-check-label'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.optional :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # bootstrap custom forms
    #
    # custom input for boolean
    config.wrappers :bs4_custom_boolean,
                    tag: 'fieldset', class: 'form-group',
                    error_class: 'form-group-invalid',
                    valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :form_check_wrapper,
                tag: 'div', class: 'custom-control custom-checkbox' do |bb|
        bb.use :input, class: 'custom-control-input', error_class: 'is-invalid', valid_class: 'is-valid'
        bb.use :label, class: 'custom-control-label'
        bb.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
        bb.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    config.wrappers :bs4_custom_boolean_switch,
                    tag: 'fieldset', class: 'form-group',
                    error_class: 'form-group-invalid',
                    valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :form_check_wrapper, tag: 'div', class: 'custom-control custom-checkbox-switch' do |bb|
        bb.use :input, class: 'custom-control-input', error_class: 'is-invalid', valid_class: 'is-valid'
        bb.use :label, class: 'custom-control-label'
        bb.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
        bb.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end

    # custom input for radio buttons and check boxes
    config.wrappers :bs4_custom_collection,
                    item_wrapper_class: 'custom-control', tag: 'fieldset',
                    class: 'form-group',
                    error_class: 'form-group-invalid',
                    valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
        ba.use :label_text
      end
      b.use :input, class: 'custom-control-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom input for inline radio buttons and check boxes
    config.wrappers :bs4_custom_collection_inline,
                    item_wrapper_class: 'custom-control custom-control-inline',
                    tag: 'fieldset', class: 'form-group',
                    error_class: 'form-group-invalid',
                    valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
        ba.use :label_text
      end
      b.use :input, class: 'custom-control-input', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom file input
    config.wrappers :bs4_custom_file, tag: 'div', class: 'form-group', error_class: 'form-group-invalid',
                                      valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :readonly
      b.use :label, class: 'form-control-label'
      b.wrapper :custom_file_wrapper, tag: 'div', class: 'custom-file' do |ba|
        ba.use :input, class: 'custom-file-input', error_class: 'is-invalid', valid_class: 'is-valid'
        ba.use :label, class: 'custom-file-label'
        ba.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      end
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom multi select
    config.wrappers :bs4_custom_multi_select, tag: 'div', class: 'form-group', error_class: 'form-group-invalid',
                                              valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :label, class: 'form-control-label'
      b.wrapper tag: 'div', class: 'd-flex flex-row justify-content-between align-items-center' do |ba|
        ba.use :input, class: 'custom-select mx-1', error_class: 'is-invalid', valid_class: 'is-valid'
      end
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom range input
    config.wrappers :bs4_custom_range, tag: 'div', class: 'form-group', error_class: 'form-group-invalid',
                                       valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :readonly
      b.optional :step
      b.use :label, class: 'form-control-label'
      b.use :input, class: 'custom-range', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # Input Group - custom component
    # see example app and config at https://github.com/rafaelfranca/simple_form-bootstrap
    # config.wrappers :bs4_input_group, tag: 'div', class: 'form-group',
    #     error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
    #   b.use :html5
    #   b.use :placeholder
    #   b.optional :maxlength
    #   b.optional :minlength
    #   b.optional :pattern
    #   b.optional :min_max
    #   b.optional :readonly
    #   b.use :label, class: 'form-control-label'
    #   b.wrapper :input_group_tag, tag: 'div', class: 'input-group' do |ba|
    #     ba.optional :prepend
    #     ba.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
    #     ba.optional :append
    #   end
    #   b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
    #   b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    # end

    # Floating Labels form
    #
    # floating labels default_wrapper
    config.wrappers :bs4_floating_labels_form, tag: 'div', class: 'form-label-group',
                                               error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.use :placeholder
      b.optional :maxlength
      b.optional :minlength
      b.optional :pattern
      b.optional :min_max
      b.optional :readonly
      b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :label, class: 'form-control-label'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end

    # custom multi select
    config.wrappers :bs4_floating_labels_select,
                    tag: 'div',
                    class: 'form-label-group',
                    error_class: 'form-group-invalid',
                    valid_class: 'form-group-valid' do |b|
      b.use :html5
      b.optional :readonly
      b.use :input, class: 'custom-select custom-select-lg', error_class: 'is-invalid', valid_class: 'is-valid'
      b.use :label, class: 'form-control-label'
      b.use :error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end
  end
end

# rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/ModuleLength
