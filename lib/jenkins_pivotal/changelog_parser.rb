module JenkinsPivotal
  class ChangelogParser
    attr_reader :entries, :data

    def initialize(path)
      @data = ''
      @entries = []

      if File.exists? path
        @data = File.read path
        load_entries
      end
    end

    private

    def load_entries
      blocks = @data.split /^(commit [a-f0-9]{40})/

      if blocks.empty?
        return
      end

      # If the first line is `commit ...`, the first item of the array will
      # be an empty string.
      if '' == blocks[0]
        blocks.shift
      end

      # The first line may be something else entirely, like:
      # Changes in branch origin/master, between ...
      if !blocks[0].start_with? 'commit'
        blocks.shift
      end

      blocks.each_slice(2) do |block|
        @entries.push ChangelogEntry.new(block[0] + block[1])
      end
    end
  end

  class ChangelogEntry
    attr_reader :author, :author_name, :author_email,
      :committer, :committer_name, :committer_email,
      :sha1, :tree, :parent,
      :message

    def initialize(data)
      @data            = data
      @message         = data.split("\n\n")[1].strip
      @sha1            = first_from_scan /^commit ([a-f0-9]{40})/
      @tree            = first_from_scan /^tree ([a-f0-9]{40})/
      @parent          = first_from_scan /^parent ([a-f0-9]{40})/
      @author          = first_from_scan /^author ((.+?) <(.+?)>)/
      @author_name     = first_from_scan /^author (.+?) </
      @author_email    = first_from_scan /^author .+? <(.+?)>/
      @committer       = first_from_scan /^committer ((.+?) <(.+?)>)/
      @committer_name  = first_from_scan /^committer (.+?) </
      @committer_email = first_from_scan /^committer .+? <(.+?)>/
    end

    private

    def first_from_scan(matcher)
      $1.strip if @data =~ matcher
    end
  end
end
