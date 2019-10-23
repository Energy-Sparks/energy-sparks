class AddValidationCacheKey < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :validation_cache_key, :string, default: 'initial'
  end
end
