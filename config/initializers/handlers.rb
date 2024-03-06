Rails.application.reloader.to_prepare do
  ActionView::Template.register_template_handler :csvrb, Handlers::CsvHandler::Handler
end
