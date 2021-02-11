# config/initializers/postgresql_database_tasks.rb
module ActiveRecord
  module Tasks
    class PostgreSQLDatabaseTasks
      def drop
        if Rails.env.development? || Rails.env.test?
          establish_master_connection
          connection.select_all "select pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where datname='#{db_config.database}' AND state='idle';"
          connection.drop_database(db_config.database)
        end
      end
    end
  end
end
