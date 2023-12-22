if Rails.application.config.action_mailer.show_previews
  Rails.env.development? || Rails::MailersController.prepend_before_action do
    authenticate_user!
    redirect_to root_path unless can?(:manage, :admin_functions)
  end
end
