module Issues
  class BulkUpdate
    def initialize(issueable:, user_from:, user_to:, updated_by:)
      @issueable = issueable
      @user_from = user_from
      @user_to = user_to
      @updated_by = updated_by
    end

    def perform
      validate!

      # Perform update and return number of records updated
      @issueable.issues
                .where(owned_by_id: @user_from)
                .update_all(
                  owned_by_id: @user_to,
                  updated_by_id: @updated_by,
                  updated_at: Time.current
                )
    end

    private

    def validate!
      errors = []
      errors << 'Issueable is required' unless @issueable

      if @user_from.blank? || @user_to.blank?
        errors << 'Both current and new admin users are required'
      elsif @user_from.to_s == @user_to.to_s
        errors << "Current and new admin users can't be the same"
      end

      raise BulkError.new(errors) if errors.any?
    end
  end

  class BulkError < StandardError
    attr_reader :messages

    def initialize(messages)
      @messages = Array(messages)
      super(@messages.join(', '))
    end
  end
end
