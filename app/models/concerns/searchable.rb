# frozen_string_literal: true

# Including classes should implement the following methods:
#
# searchable_body_field - name of field containing body text
# searchable_metadata_fields - array of additional field names to query
# searchable_filter - WHERE clause that filter the matched records, e.g. to those visible to end user
module Searchable
  extend ActiveSupport::Concern

  class_methods do # rubocop:disable Metrics/BlockLength -- splitting queries would only make more complicated
    def search(query:, locale: :en, show_all: false)
      sql = build_translated_search_sql(query:, locale:, show_all:)
      select("#{table_name}.*, search_results.rank, search_results.headline")
        .joins(sql)
        .order('search_results.rank desc', "#{table_name}.id")
    end

    private

    def build_translated_search_sql(query:, locale: :en, show_all: false)
      metadata_fields = searchable_metadata_fields.map { |s| "'#{s}'" }.join(', ')
      quoted_query = quote(query)
      table = ActiveRecord::Base.connection.quote_table_name(table_name)
      dictionary = quote(dictionary_for(locale))
      tsvector_sql = build_tsvector_sql(dictionary)
      tsquery_sql = "websearch_to_tsquery(#{dictionary}, #{quoted_query})"
      filter = searchable_filter(show_all:)
      quoted_record_type = quote(name)
      quoted_locale = quote(locale)

      <<~SQL.squish
        INNER JOIN (
          SELECT
            #{table}.id AS search_id,
            ts_rank(#{tsvector_sql}, #{tsquery_sql}) AS rank,
            ts_headline(#{dictionary}, #{build_body_sql}, #{tsquery_sql}, 'MaxFragments=1') AS headline

          FROM #{table}

          LEFT OUTER JOIN (
            SELECT
              #{table}.id AS id,
              action_text_rich_texts.body::text AS body_field_text
            FROM #{table}
            INNER JOIN action_text_rich_texts
              ON action_text_rich_texts.record_type = #{quoted_record_type}
              AND action_text_rich_texts.name = #{quote(searchable_body_field)}
              AND action_text_rich_texts.locale = #{quoted_locale}
              AND action_text_rich_texts.record_id = #{table}.id
            WHERE #{filter}
          ) rich_texts
            ON rich_texts.id = #{table}.id

          LEFT OUTER JOIN (
            SELECT
              #{table}.id AS id,
              string_agg(mobility_string_translations.value::text, ' ') AS metadata_fields_text
            FROM #{table}
            INNER JOIN mobility_string_translations
              ON mobility_string_translations.translatable_type = #{quoted_record_type}
              AND mobility_string_translations.key IN (#{metadata_fields})
              AND mobility_string_translations.translatable_id = #{table}.id
              AND mobility_string_translations.locale = #{quoted_locale}
            WHERE #{filter}
            GROUP BY #{table}.id
          ) mobility_strings
            ON mobility_strings.id = #{table}.id

          WHERE #{tsvector_sql} @@ #{tsquery_sql}
        ) AS search_results
          ON #{table}.id = search_results.search_id
      SQL
    end

    def build_tsvector_sql(dictionary)
      <<~SQL.squish
        (to_tsvector(#{dictionary}, coalesce(rich_texts.body_field_text::text, ''))
         ||
         to_tsvector(#{dictionary}, coalesce(mobility_strings.metadata_fields_text::text, '')))
      SQL
    end

    def build_body_sql
      <<~SQL.squish
        (coalesce(rich_texts.body_field_text::text, '')
         ||
         coalesce(mobility_strings.metadata_fields_text::text, ''))
      SQL
    end

    def dictionary_for(locale)
      locale.to_s == 'en' ? 'english' : 'simple'
    end

    def quote(query) = ActiveRecord::Base.connection.quote(query)
  end
end
