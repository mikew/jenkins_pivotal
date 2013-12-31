require 'json'
require 'rest-client'

module JenkinsPivotal
  class Client
    attr_reader :token, :acceptor_token, :connection

    def initialize(options)
      @token = options[:token]
      @acceptor_token = options[:acceptor_token]

      headers = {
        'X-TrackerToken' => token,
        'Content-Type' => 'application/json'
      }

      @connection = RestClient::Resource.new api_url, headers: headers
    end

    def post_source_commits(payload)
      begin
        connection['/source_commits'].post payload.to_json
      rescue => e
        puts e.message
        puts e.http_body
      end
    end

    def api_url
      'https://www.pivotaltracker.com/services/v5'
    end
  end
end
