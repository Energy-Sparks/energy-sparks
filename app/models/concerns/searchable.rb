module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search(query:, locale:)
      where(id: select("DISTINCT #{name.underscore.pluralize}.id, search_type_results.rank").joins(sanitized_sql_for(locale, query)).pluck(:id))
    end

    def sanitized_sql_for(locale, query)
      ActiveRecord::Base.sanitize_sql_array(
        [
          build_translation_search_sql,
          { locale: locale.to_s, dictionary: dictionary_for(locale), query: query&.delete("'") }
        ]
      )
    end

    def dictionary_for(locale)
      locale.to_s == 'en' ? 'english' : 'simple'
    end

    def build_translation_search_sql
      table = name.underscore.pluralize
      search_sql = <<-SQL.squish
        INNER JOIN (
          SELECT "#{table}"."id" AS search_id, (
            ts_rank(
              (
                to_tsvector(:dictionary, coalesce(action_text_rich_texts_results.action_text_rich_texts_body::text, ''))
                ||
                to_tsvector(:dictionary, coalesce(mobility_string_translations_results.mobility_string_translations_value::text, ''))
              ),
              (
                to_tsquery(:dictionary, ''' ' || :query || ' ''')
              ), 0
            )
          ) AS rank FROM "#{table}"

          LEFT OUTER JOIN (
            SELECT "#{table}"."id" AS id, "action_text_rich_texts"."body"::text AS action_text_rich_texts_body
            FROM "#{table}"
            INNER JOIN "action_text_rich_texts" ON "action_text_rich_texts"."record_type" = '#{name}'
            AND "action_text_rich_texts"."name" = 'description'
            AND "action_text_rich_texts"."locale" = :locale
            AND "action_text_rich_texts"."record_id" = "#{table}"."id"
            WHERE "#{table}"."active" = 'true'
          ) action_text_rich_texts_results ON action_text_rich_texts_results.id = "#{table}"."id"

          LEFT OUTER JOIN (
            SELECT "#{table}"."id" AS id, string_agg("mobility_string_translations"."value"::text, ' ') AS mobility_string_translations_value
            FROM "#{table}"
            INNER JOIN "mobility_string_translations" ON "mobility_string_translations"."translatable_type" = '#{table}'
            AND "mobility_string_translations"."key" IN ('name', 'summary')
            AND "mobility_string_translations"."translatable_id" = "#{table}"."id"
            AND "mobility_string_translations"."locale" = :locale
            WHERE "#{table}"."active" = 'true'
            GROUP BY "#{table}"."id"
          ) mobility_string_translations_results ON mobility_string_translations_results.id = "#{table}"."id"

          WHERE (
            (
              to_tsvector(:dictionary, coalesce(action_text_rich_texts_results.action_text_rich_texts_body::text, ''))
              ||
              to_tsvector(:dictionary, coalesce(mobility_string_translations_results.mobility_string_translations_value::text, ''))
            )
            @@
            (
              to_tsquery(:dictionary, ''' ' || :query || ' ''')
            )
          )
        ) AS search_type_results ON "#{table}"."id" = search_type_results.search_id

        ORDER BY search_type_results.rank DESC, "#{table}"."id" ASC
      SQL

      search_sql
    end
  end
end
