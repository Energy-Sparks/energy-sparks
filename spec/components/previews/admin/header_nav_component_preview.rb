module Admin
  class HeaderNavComponentPreview < ViewComponent::Preview
    def default
      render Admin::HeaderNavComponent.new do |header_nav|
        header_nav.with_header title: 'My title'
        header_nav.with_button 'New', new_admin_case_study_path
        header_nav.with_button 'Case studies', admin_case_studies_path
      end
    end
  end
end
