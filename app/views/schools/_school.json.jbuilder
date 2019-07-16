# frozen_string_literal: true

json.extract! school, :id, :name, :school_type, :address, :postcode, :website, :created_at, :updated_at
json.url school_url(school, format: :json)
