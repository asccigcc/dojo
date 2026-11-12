module DojoRunner
  # A fresh temp directory holding one run's files. Always removed afterwards.
  class Workspace
    RESULT_FILE = ".dojo-result.json"
    MAX_RESULT_BYTES = 1_000_000

    attr_reader :dir

    # Creates the workspace, yields it, and deletes it no matter what.
    #
    # @param files [Hash{String=>String}] validated relative path => content
    # @param root [String] parent directory (tmpfs in the container)
    # @yieldparam workspace [Workspace]
    # @return [Object] the block's value
    def self.open(files, root: Dir.tmpdir)
      dir = Dir.mktmpdir("run-", root)
      yield new(dir).tap { |workspace| workspace.write(files) }
    ensure
      FileUtils.rm_rf(dir) if dir
    end

    # @param dir [String]
    def initialize(dir)
      @dir = dir
    end

    # @param files [Hash{String=>String}]
    # @return [void]
    def write(files)
      files.each do |path, content|
        target = File.join(dir, path)
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, content)
      end
    end

    # @return [String] where the harness writes its JSON verdict
    def result_path = File.join(dir, RESULT_FILE)

    # @return [Hash, nil] the harness verdict, or nil if it never got written
    def read_result
      JSON.parse(File.read(result_path, MAX_RESULT_BYTES))
    rescue Errno::ENOENT, JSON::ParserError
      nil
    end
  end
end
