module Todos
  module Recording
    extend ActiveSupport::Concern
    # For models which can be completed as part of a todo, such as activity and observation

    included do
      has_many :completed_todos, as: :recording, dependent: :destroy

      has_many :programmes_completed_todos, through: :completed_todos, source: :completable, source_type: 'Programme'
      has_many :audits_completed_todos, through: :completed_todos, source: :completable, source_type: 'Audit'
    end
  end
end
