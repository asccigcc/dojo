module Content
  # One warm-up rep file (content/ruby/warmups/<set>/<rep>.yml) mapped onto
  # Exercise attributes.
  class WarmupSource
    # @param path [Pathname] the rep's YAML file
    # @param data_code [String] shared data.rb, prepended to every rep's prelude
    def initialize(path, data_code)
      @doc = YAML.safe_load_file(path)
      @data_code = data_code
    end

    # @return [String]
    def slug = @doc.fetch("slug")

    # @return [Hash] attributes for Exercise#update!
    def attributes
      { kind: "warmup", language: "ruby", category: @doc.fetch("category"), title: @doc.fetch("title"),
        position: @doc.fetch("position"), parts_count: 1, description_md:, starter_code: "",
        prelude_code:, expected_code: @doc.fetch("expected"), solution_code: @doc.fetch("answer"),
        notes_md: @doc["note"], test_code: nil, code_path: nil, test_path: nil }
    end

    # @return [Hash] warm-ups have no parts
    def parts = {}

    private

    def prelude_code = [ @data_code, @doc["setup"] ].compact.map { |code| code.chomp + "\n" }.join

    def description_md
      [ @doc.fetch("prompt"), @doc["returns"], "**Expected:** `#{@doc.fetch('expected')}`" ].compact.join("\n\n")
    end
  end
end
