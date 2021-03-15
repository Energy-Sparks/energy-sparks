module ConsentStatements
  class Publisher
    attr_reader :error_message

    def initialize
      @error_message = ''
    end

    def publish(consent_statement)
      ConsentStatement.transaction do
        ConsentStatement.all.update(current: false)
        consent_statement.update(current: true)
      end
      true
    rescue => e
      @error_message = "Failed to publish consent statement: #{e.message}"
      false
    end
  end
end
