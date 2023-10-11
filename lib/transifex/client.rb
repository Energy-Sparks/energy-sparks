module Transifex
  class Client
    class ApiFailure < StandardError; end
    class BadRequest < StandardError; end
    class NotFound < StandardError; end
    class NotAllowed < StandardError; end
    class NotAuthorised < StandardError; end
    class ResponseError < StandardError; end
    class AccessError < StandardError; end

    BASE_URL = 'https://rest.api.transifex.com/'.freeze
    ORGANIZATION = 'energy-sparks'.freeze
    CONTENT_TYPE_JSON = 'application/vnd.api+json'.freeze

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
      url = add_filter('resources')
      get_data(url)
    end

    def get_resource(slug)
      url = make_url("resources/#{resource_id(slug)}")
      get_data(url)
    end

    def delete_resource(slug)
      raise AccessError, "#{slug} in #{@project} is not deletable" unless resource_is_deletable

      url = make_url("resources/#{resource_id(slug)}")
      del_data(url)
    end

    def create_resource(name, slug, categories = [], priority = 'normal')
      url = make_url('resources')
      post_data(url, resource_data(name, slug, project_id, categories, priority))
    end

    def create_resource_strings_async_upload(slug, content)
      url = make_url('resource_strings_async_uploads')
      post_data(url, resource_strings_async_upload_data(resource_id(slug), content))
    end

    def get_resource_strings_async_upload(resource_strings_async_upload_id)
      url = make_url("resource_strings_async_uploads/#{resource_strings_async_upload_id}")
      get_data(url) do |response|
        process_async_upload_response(response)
      end
    end

    def create_resource_translations_async_downloads(slug, language, mode = 'onlyreviewed')
      url = make_url('resource_translations_async_downloads')
      post_data(url, resource_translations_async_downloads_data(resource_id(slug), language, mode))
    end

    def get_resource_translations_async_download(resource_translations_async_download_id)
      url = make_url("resource_translations_async_downloads/#{resource_translations_async_download_id}")
      get_data(url) do |response|
        process_async_download_response(response)
      end
    end

    def get_resource_language_stats(slug = nil, language = nil)
      url = if slug && language
              make_url("resource_language_stats/#{resource_language_id(slug, language)}")
            else
              add_filter('resource_language_stats')
            end
      get_data(url)
    end

    private

    def headers
      {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => CONTENT_TYPE_JSON
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
      @connection ||= Faraday.new(BASE_URL, headers: headers) { |f| f.use FaradayMiddleware::FollowRedirects }
    end

    def get_data(url)
      response = connection.get(url)
      check_response_status(response)
      block_given? ? yield(response) : process_response(response)
    end

    def post_data(url, data)
      response = connection.post(url, data.to_json)
      check_response_status(response)
      process_response(response)
    end

    def del_data(url)
      response = connection.delete(url)
      check_response_status(response)
    end

    def check_response_status(response)
      raise BadRequest, error_message(response) if response.status == 400
      raise NotAuthorised, error_message(response) if response.status == 401
      raise NotAllowed, error_message(response) if response.status == 403
      raise NotFound, error_message(response) if response.status == 404
      raise ApiFailure, error_message(response) unless response.success?

      true
    end

    def process_response(response)
      JSON.parse(response.body)['data']
    end

    def process_async_download_response(response)
      if json?(response)
        data = process_response(response)
        process_errors(data)
        Response.new(completed: false, data: data)
      else
        Response.new(completed: true, content: response.body)
      end
    end

    def process_async_upload_response(response)
      data = process_response(response)
      process_errors(data)
      completed = (data['attributes']['status'] == 'succeeded')
      Response.new(completed: completed, data: data)
    end

    def process_errors(data)
      raise ResponseError, error_messages(data['attributes']['errors']) if data['attributes']['errors'].present?
    end

    def error_messages(errors)
      errors.map { |error| error['code'] + ': ' + error['detail'] }.join('\n')
    end

    def json?(response)
      response.headers['content-type'].include?(CONTENT_TYPE_JSON)
    end

    def error_message(response)
      data = JSON.parse(response.body)
      if data['errors']
        error_messages(data['errors'])
      else
        response.body
      end
    rescue StandardError
      # problem parsing or traversing json, return original api error
      response.body
    end

    def resource_is_deletable
      if (deletable_projects = ENV['TRANSIFEX_DELETABLE_PROJECTS'])
        return deletable_projects.split(',').include?(@project)
      end

      false
    end

    def resource_strings_async_upload_data(resource_id, content)
      {
        "data": {
          "attributes": {
            "content": content,
            "content_encoding": 'text'
          },
          "relationships": {
            "resource": {
              "data": {
                "id": resource_id,
                "type": 'resources'
              }
            }
          },
          "type": 'resource_strings_async_uploads'
        }
      }
    end

    def resource_data(name, slug, project_id, categories, priority)
      {
        "data": {
          "attributes": {
            "accept_translations": true,
            "categories": categories,
            "name": name,
            "priority": priority,
            "slug": slug
          },
          "relationships": {
            "i18n_format": {
              "data": {
                "id": 'YML_KEY',
                "type": 'i18n_formats'
              }
            },
            "project": {
              "data": {
                "id": project_id,
                "type": 'projects'
              }
            }
          },
          "type": 'resources'
        }
      }
    end

    def resource_translations_async_downloads_data(resource_id, language, mode)
      {
        "data": {
          "attributes": {
            "content_encoding": 'text',
            "file_type": 'default',
            "mode": mode,
            "pseudo": false
          },
          "relationships": {
            "language": {
              "data": {
                "id": "l:#{language}",
                "type": 'languages'
              }
            },
            "resource": {
              "data": {
                "id": resource_id,
                "type": 'resources'
              }
            }
          },
          "type": 'resource_translations_async_downloads'
        }
      }
    end
  end
end
