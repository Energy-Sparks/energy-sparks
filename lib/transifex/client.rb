module Transifex
  class Client
    class ApiFailure < StandardError; end
    class BadRequest < StandardError; end
    class NotFound < StandardError; end
    class NotAllowed < StandardError; end
    class NotAuthorised < StandardError; end

    BASE_URL = 'https://rest.api.transifex.com/'.freeze
    ORGANIZATION = 'energy-sparks'.freeze

    def initialize(api_key, project, connection = nil)
      @api_key = api_key
      @project = project
      @connection = connection
    end

    def get_languages
      url = make_url("projects/#{project_id}/languages")
      get_data(url)
    end

    def list_resources
      url = add_filter("resources")
      get_data(url)
    end

    def create_resource(name, slug)
      url = make_url("resources")
      post_data(url, resource_data(name, slug, project_id))
    end

    def create_resource_strings_async_upload(slug, content)
      url = make_url("resource_strings_async_uploads")
      post_data(url, resource_strings_async_upload_data(resource_id(slug), content))
    end

    def get_resource_strings_async_upload(resource_strings_async_upload_id)
      url = make_url("resource_strings_async_uploads/#{resource_strings_async_upload_id}")
      get_data(url)
    end

    def get_resource_language_stats(slug = nil, language = nil)
      if slug && language
        url = make_url("resource_language_stats/#{resource_language_id(slug, language)}")
      else
        url = add_filter("resource_language_stats")
      end
      get_data(url)
    end

    private

    def headers
      {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/vnd.api+json'
      }
    end

    def add_filter(path)
      path + "?filter[project]=#{project_id}"
    end

    def make_url(path)
      path
    end

    def project_id
      "o:#{ORGANIZATION}:p:#{@project}"
    end

    def resource_id(slug)
      "#{project_id}:r:#{slug}"
    end

    def resource_language_id(slug, language)
      "#{resource_id(slug)}:l:#{language}"
    end

    def connection
      @connection ||= Faraday.new(BASE_URL, headers: headers)
    end

    def get_data(url)
      response = connection.get(url)
      process_response(response)
    end

    def post_data(url, data)
      response = connection.post(url, data.to_json)
      process_response(response)
    end

    def process_response(response)
      raise BadRequest.new(error_message(response)) if response.status == 400
      raise NotAuthorised.new(error_message(response)) if response.status == 401
      raise NotAllowed.new(error_message(response)) if response.status == 403
      raise NotFound.new(error_message(response)) if response.status == 404
      raise ApiFailure.new(error_message(response)) unless response.success?

      # dump to console for setting up test data files
      # puts JSON.pretty_generate(JSON.parse(response.body), :indent => "\t")

      JSON.parse(response.body)['data']
    end

    def error_message(response)
      data = JSON.parse(response.body)
      if data['errors']
        error = data['errors'][0]
        error['title'] + ' : ' + error['detail']
      else
        response.body
      end
    rescue
      #problem parsing or traversing json, return original api error
      response.body
    end

    def resource_strings_async_upload_data(resource_id, content)
      {
        "data": {
          "attributes": {
            "content": content,
            "content_encoding": "text"
          },
          "relationships": {
            "resource": {
              "data": {
                "id": resource_id,
                "type": "resources"
              }
            }
          },
          "type": "resource_strings_async_uploads"
        }
      }
    end

    def resource_data(name, slug, project_id)
      {
        "data": {
          "attributes": {
            "accept_translations": true,
            "name": name,
            "slug": slug,
          },
          "relationships": {
            "i18n_format": {
              "data": {
                "id": "YML_KEY",
                "type": "i18n_formats"
              }
            },
            "project": {
              "data": {
                "id": project_id,
                "type": "projects"
              }
            }
          },
          "type": "resources"
        }
      }
    end
  end
end
