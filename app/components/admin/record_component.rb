module Admin
  # Component for showing internal metadata for an active model record
  class RecordComponent < ApplicationComponent
    def initialize(record, **_kwargs)
      super
      @record = record
    end

    def render?
      current_user&.admin?
    end

    private

    def created_by
      @record.try(:created_by)
    end

    def updated_by
      @record.try(:updated_by)
    end
  end
end
