# z_ file prefix means this gets loaded after other initializers so AR config is set

require 'after_party'
AfterParty.setup do |_config|
  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'after_party/active_record'
end
