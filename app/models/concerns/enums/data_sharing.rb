module Enums::DataSharing
  extend ActiveSupport::Concern

  # Defined as Postgres Enum. Mapping is from ruby values to database values
  ENUM_DATA_SHARING = {
    public: 'public',
    within_group: 'within_group',
    private: 'private'
  }.freeze

  included do
    enum :data_sharing, ENUM_DATA_SHARING, prefix: true
  end
end
