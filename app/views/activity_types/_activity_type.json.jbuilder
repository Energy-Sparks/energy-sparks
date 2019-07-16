# frozen_string_literal: true

json.extract! activity_type, :id, :name, :description, :created_at, :updated_at
json.url activity_type_url(activity_type, format: :json)
