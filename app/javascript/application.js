// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import 'trix'
import '@rails/actiontext'

// per https://github.com/basecamp/trix/pull/434
Trix.config.attachments.preview.caption = { name: false, size: false }
