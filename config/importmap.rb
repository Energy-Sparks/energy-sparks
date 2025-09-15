# Pin npm packages by running ./bin/importmap

pin 'application'

pin 'trix'
pin '@rails/actiontext', to: 'actiontext.js'

pin 'transport_surveys/storage', preload: false
pin 'transport_surveys/carbon', preload: false
pin 'transport_surveys/notifier', preload: false
pin 'transport_surveys/handlebars_helpers', preload: false
pin 'transport_surveys/helpers', preload: false
pin 'bootstrap' # @5.3.8
pin '@popperjs/core', to: '@popperjs--core.js' # @2.11.8
