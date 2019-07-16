# frozen_string_literal: true

json.extract! activity_category, :id, :name, :created_at, :updated_at
json.url activity_category_url(activity_category, format: :json)
