module Database
  class VacuumService
    def initialize(tables)
      @tables = tables
    end

    def perform
      @tables.each do |table|
        begin
          ActiveRecord::Base.connection.execute("VACUUM ANALYSE #{table}")
        rescue StandardError => exception
          message = "VACUUM ANALYSE #{table} error: #{exception.message}"
          Rails.logger.error(message)
          Rollbar.error(message)
        end
      end
    end
  end
end
