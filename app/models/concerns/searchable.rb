# Including classes should implement the following methods:
#
# searchable_body_field - name of field containing body text
# searchable_metadata_fields - array of additional field names to query
# searchable_filter - WHERE clause that filter the matched records, e.g. to those visible to end user
module Searchable
  extend ActiveSupport::Concern

  class_methods do # rubocop:disable Metrics/BlockLength -- splitting queries would only make more complicated
    def search(query:, locale: :en, show_all: false)
      sql = ActiveRecord::Base.sanitize_sql_array(build_translated_search_sql(query:, locale:, show_all:))
      select("#{table_name}.*, search_results.rank, search_results.headline").joins(sql)
                                                         .order('search_results.rank desc', "#{table_name}.id")
    end

    private

    def sanitize_websearch_query(query)
      query.gsub(/['?\\:]/, ' ')
    end

    def build_translated_search_sql(query:, locale: :en, show_all: false)
      dictionary = dictionary_for(locale)
      metadata_fields = searchable_metadata_fields.map { |s| "'#{s}'" }.join(', ')
      search = ActiveRecord::Base.connection.quote(sanitize_websearch_query(query))
      <<~SQL.squish
        INNER JOIN (
          SELECT
            "#{table_name}"."id" AS search_id,
            ts_rank(
              (
                to_tsvector('#{dictionary}', coalesce(rich_texts.body_field_text::text, ''))
                ||
                to_tsvector('#{dictionary}', coalesce(mobility_strings.metadata_fields_text::text, ''))
              ),
              (
                websearch_to_tsquery('#{dictionary}', #{search})
              )
            ) AS rank,
            ts_headline(
              '#{dictionary}',
              (
                coalesce(rich_texts.body_field_text::text, '') ||
                coalesce(mobility_strings.metadata_fields_text::text, '')
              ),
              websearch_to_tsquery('#{dictionary}', #{search}),
              'MaxFragments=1'
            ) AS headline
          FROM "#{table_name}"
          LEFT OUTER JOIN (
              SELECT
                "#{table_name}"."id" AS id,
                "action_text_rich_texts"."body"::text AS body_field_text
              FROM "#{table_name}"
              INNER JOIN
                "action_text_rich_texts" ON "action_text_rich_texts"."record_type" = '#{name}'
              AND "action_text_rich_texts"."name" = '#{searchable_body_field}'
              AND "action_text_rich_texts"."locale" = '#{locale}'
              AND "action_text_rich_texts"."record_id" = "#{table_name}"."id"
              WHERE #{searchable_filter(show_all:)}
          ) rich_texts ON rich_texts.id = "#{table_name}"."id"
          LEFT OUTER JOIN (
              SELECT
                "#{table_name}"."id" AS id,
                string_agg("mobility_string_translations"."value"::text, ' ') AS metadata_fields_text
              FROM "#{table_name}"
              INNER JOIN
                "mobility_string_translations" ON "mobility_string_translations"."translatable_type" = '#{name}'
              AND "mobility_string_translations"."key" IN (#{metadata_fields})
              AND "mobility_string_translations"."translatable_id" = "#{table_name}"."id"
              AND "mobility_string_translations"."locale" = '#{locale}'
              WHERE #{searchable_filter(show_all:)}
              GROUP BY "#{table_name}"."id"
          ) mobility_strings ON mobility_strings.id = "#{table_name}"."id"
          WHERE (
              to_tsvector('#{dictionary}', coalesce(rich_texts.body_field_text::text, ''))
              ||
              to_tsvector('#{dictionary}', coalesce(mobility_strings.metadata_fields_text::text, ''))
          ) @@ (
              websearch_to_tsquery('#{dictionary}', #{search})
          )
        ) AS search_results ON "#{table_name}"."id" = search_results.search_id
      SQL
    end

    def dictionary_for(locale)
      locale.to_s == 'en' ? 'english' : 'simple'
    end
  end
end
