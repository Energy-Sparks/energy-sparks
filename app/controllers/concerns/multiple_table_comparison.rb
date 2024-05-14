# To be included by comparison reports that include multiple tables
#
# Including classes should implement the +table_configuration+ method
module MultipleTableComparison
  extend ActiveSupport::Concern

  included do
    helper_method :table_title
    helper_method :table_number_and_title
  end

  def table_names
    table_configuration.keys
  end

  # Override to return a hash of table names => table titles
  #
  # Table names should be a symbol and correspond to a partial in the
  # views folder for the comparison
  #
  # The table title should be the translated title for the table
  def table_configuration
    {}
  end

  def table_title(table_name)
    table_configuration[table_name]
  end

  def table_number_and_title(table_number, table_name)
    title = table_configuration[table_name]
    I18n.t('comparisons.tables.table_number', table_number: table_number) + (title.present? ? ": #{title}" : '')
  end
end
