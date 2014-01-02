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
      all_entries = []
      changelog_paths.each do |path|
        parser = ChangelogParser.new path
        all_entries.concat parser.entries
      end

      all_entries.each do |entry|
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

    def changelog_paths
      # TODO this should be extracted into ChangelogGatherer or something
      if ENV['CHANGELOG_PATH']
        return [ ENV['CHANGELOG_PATH'] ]
      end

      start_from = 1
      default_changelog = File.join env_variables['JENKINS_HOME'],
        'jobs', env_variables['JOB_NAME'],
        'builds', env_variables['BUILD_NUMBER'],
        'changelog.xml'

      # If it's the first build, there's nothing to gather.
      if env_variables['BUILD_NUMBER'] == '1'
        return [ default_changelog ]
      end

      last_success = File.join env_variables['JENKINS_HOME'],
        'jobs', env_variables['JOB_NAME'],
        'builds', 'lastSuccessfulBuild'

      last_success_num = File.readlink last_success
      if last_success_num != '-1'
        # If the lastSuccessfulBuild was the previous build then the
        # changelog will already be adequate.
        if last_success_num.to_i == env_variables['BUILD_NUMBER'].to_i - 1
          return [ default_changelog ]
        else
          start_from = last_success_num.to_i + 1
        end
      end

      start_from.upto(env_variables['BUILD_NUMBER'].to_i).map do |i|
        File.join env_variables['JENKINS_HOME'],
          'jobs', env_variables['JOB_NAME'],
          'builds', i.to_s,
          'changelog.xml'
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
        'jobs', ENV['JOB_NAME'],
        'builds', ENV['BUILD_NUMBER'],
        'changelog.xml'
    end
  end
end
