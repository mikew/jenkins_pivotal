module JenkinsPivotal
  class Agent
    attr_reader :token, :project, :message, :url, :current_entry, :file,
      :acceptor_token

    def initialize(options)
      @token = options[:token]
      @project = options[:project].to_i
      @message = options[:message]
      @file = options[:file]
      @url = options[:url]
      @acceptor_token = options[:acceptor_token]
      @current_entry = nil
    end

    def file_contents
      if file
        File.read(file).strip
      end
    end

    def browser_url
      if url
        url % current_entry.sha1
      end
    end

    def client
      @_client ||= Client.new token: token, acceptor_token: acceptor_token
    end

    def message_to_post
      given_message = nil

      if message
        given_message = message
      end

      if file
        given_message = file_contents
      end

      if given_message
        formatted = given_message % message_variables
        return "#{formatted}\n\n#{current_entry.message}"
      end

      current_entry.message
    end

    def message_variables
      env_variables.inject({}) do |memo, (k, v)|
        memo[k.to_sym] = v
        memo
      end
    end

    def should_deliver(msg)
      ret = []
      refs = msg.scan /\[((?:.*?)([#0-9 ]+)(?:.*?))\]/

      refs.each do |group|
        if group[0].downcase.include? 'deliver'
          ids = group[1].strip.split
          ret.concat ids.map { |i| i.gsub('#', '').to_i }
        end
      end

      return ret
    end

    def run!
      parser = ChangelogParser.new changelog_path
      parser.entries.each do |entry|
        @current_entry = entry

        payload = {
          source_commit: {
            url: browser_url,
            message: message_to_post,
            author: current_entry.author_name,
            commit_id: current_entry.sha1
          }
        }

        client.post_source_commits payload

        should_deliver(current_entry.message).each do |story_id|
          client.deliver_to_acceptor project, story_id
        end
      end
    end

    private

    def env_variables
      ENV
    end

    def changelog_path
      if ENV['CHANGELOG_PATH']
        return ENV['CHANGELOG_PATH']
      end

      File.join ENV['JENKINS_HOME'],
        'jobs',
        ENV['JOB_NAME'],
        'builds',
        ENV['BUILD_NUMBER'],
        'changelog.xml'
    end
  end
end
