Rails.application.reloader.to_prepare do
  ActionView::Template.register_template_handler :data, Handlers::CsvHandler::Handler
end
