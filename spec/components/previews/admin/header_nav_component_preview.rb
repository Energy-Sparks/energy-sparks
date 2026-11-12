# frozen_string_literal: true

module Admin
  class HeaderNavComponentPreview < ViewComponent::Preview
    # @param bs5 toggle
    def default(bs5: true) # rubocop:disable Lint/UnusedMethodArgument
      render Admin::HeaderNavComponent.new do |header_nav|
        header_nav.with_header title: 'My title'
        header_nav.with_button 'New', new_admin_case_study_path
        header_nav.with_button 'Case studies', admin_case_studies_path
      end
    end

    # @param bs5 toggle
    def with_default_size_buttons(bs5: true) # rubocop:disable Lint/UnusedMethodArgument
      render Admin::HeaderNavComponent.new do |header_nav|
        header_nav.with_header title: 'My title'
        header_nav.with_button 'New', new_admin_case_study_path, size: nil
        header_nav.with_button 'Case studies', admin_case_studies_path, size: nil
      end
    end

    # @param bs5 toggle
    def with_dropdown(bs5: true) # rubocop:disable Lint/UnusedMethodArgument
      render Admin::HeaderNavComponent.new do |header_nav|
        header_nav.with_header title: 'My title'
        header_nav.with_dropdown title: 'Jump to',
                                 items: [['One', '#one'], ['Two', '#two']],
                                 classes: 'me-2'
        header_nav.with_button 'New', new_admin_case_study_path, style: :primary, size: nil
      end
    end

    # @param bs5 toggle
    def with_mixed_actions(bs5: true) # rubocop:disable Lint/UnusedMethodArgument
      render Admin::HeaderNavComponent.new do |header_nav|
        header_nav.with_header title: 'My title'
        header_nav.with_button 'First', new_admin_case_study_path
        header_nav.with_dropdown title: 'First menu', items: [['One', '#one']]
        header_nav.with_dropdown title: 'Second menu', items: [['Two', '#two']]
        header_nav.with_button 'Last', admin_case_studies_path, style: :primary
      end
    end
  end
end
