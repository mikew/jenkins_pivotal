require 'json'
require 'rest-client'

module JenkinsPivotal
  class Client
    attr_reader :connection

    def initialize(options)
      @options = options
      @connection = build_connection options[:token]
      load_acceptor if options[:acceptor_token]
    end

    def load_acceptor
      acceptor_conn = build_connection @options[:acceptor_token]
      json = JSON.parse acceptor_conn['/me'].get
      @acceptor_id = json['id']
      @acceptor_name = json['name']
    end

    def post_source_commits(payload)
      begin
        connection['/source_commits'].post payload.to_json
      rescue => e
        puts e.message
        puts e.http_body
      end
    end

    def deliver_to_acceptor(project, story_id)
      return unless @acceptor_id

      begin
        endpoint = "projects/#{project}/stories/#{story_id}"
        payload = { owned_by_id: @acceptor_id }
        connection[endpoint].put payload.to_json
      rescue => e
        puts e.message
        puts e.http_body
      end
    end

    def api_url
      'https://www.pivotaltracker.com/services/v5'
    end

    private

    def build_connection(token)
      headers = {
        'X-TrackerToken' => token,
        'Content-Type' => 'application/json'
      }

      RestClient::Resource.new api_url, headers: headers
    end
  end
end
