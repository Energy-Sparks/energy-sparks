if Rails.application.config.action_mailer.show_previews
  Rails::MailersController.prepend_before_action do
    unless Rails.env.development?
      authenticate_user!
      head :forbidden unless current_user.admin? && can?(:manage, :admin_functions)
    end
  end
end
