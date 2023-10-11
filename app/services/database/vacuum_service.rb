module Database
  class VacuumService
    def initialize(tables)
      @tables = tables
    end

    ## NB: VACUUM does not work when run inside a transaction block
    ## For rspec, use ts: false as an argument to the block to prevent tests being wrapped in a transaction block
    def perform
      @tables.each do |table|
        ActiveRecord::Base.connection.execute("VACUUM ANALYSE #{table}")
      rescue StandardError => e
        message = "VACUUM ANALYSE #{table} error: #{e.message}"
        Rails.logger.error(message)
        Rollbar.error(message)
      end
    end
  end
end
