# Pin npm packages by running ./bin/importmap

pin 'application_importmap'

pin 'transport_surveys/storage', preload: false
pin 'transport_surveys/carbon', preload: false
pin 'transport_surveys/notifier', preload: false
pin 'transport_surveys/handlebars_helpers', preload: false
pin 'transport_surveys/helpers', preload: false

pin 'trix'
pin '@rails/actiontext', to: 'actiontext.js'
