# Pin npm packages by running ./bin/importmap

pin 'application'

pin 'trix'
pin '@rails/actiontext', to: 'actiontext.js'

pin 'transport_surveys/storage', preload: false
pin 'transport_surveys/carbon', preload: false
pin 'transport_surveys/notifier', preload: false
pin 'transport_surveys/handlebars_helpers', preload: false
pin 'transport_surveys/helpers', preload: false

pin_all_from 'app/javascript/commercial', under: 'commercial', preload: false
