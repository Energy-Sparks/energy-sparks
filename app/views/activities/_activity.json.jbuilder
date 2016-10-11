json.extract! activity, :id, :school_id, :activity_type_id, :title, :description, :happened_on, :created_at, :updated_at
json.url activity_url(activity, format: :json)