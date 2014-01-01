require 'slop'

module JenkinsPivotal
  class Cli
    attr_reader :options

    def initialize(items = ARGV)
      @options = Slop.parse(items, help: true) do
        banner "Usage: #{$0} [options...]"

        on 't', 'token=', 'Tracker API token.'
        on 'p', 'project=', 'Tracker Project ID.', as: :integer
        on 'm', 'message=', 'Message to add.'
        on 'f', 'file=', 'Read message from file.'
        on 'u', 'url=', 'URL to browse commit.'
        on 'a', 'acceptor-token=', 'Tracker token of acceptor.'

        on 'v', 'version', 'Display version information.' do
          puts "#{$0} #{JenkinsPivotal::VERSION}"
          exit 0
        end
      end
    end

    def run!
      unless options.token? && options.project?
        puts @options
        exit 1
      end

      Agent.new(
        token: options[:token],
        project: options[:project],
        message: options[:message],
        file: options[:file],
        url: options[:url],
        acceptor_token: options[:'acceptor-token']
      ).run!
    end
  end
end
