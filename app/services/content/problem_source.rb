module Content
  # One problem directory (content/ruby/problems/NN-slug/) mapped onto
  # Exercise attributes plus its parts.
  class ProblemSource
    # @param dir [Pathname] the problem directory
    # @param test_helper [String] shared minitest helper (PART gating)
    def initialize(dir, test_helper)
      @dir = dir
      @test_helper = test_helper
      @meta = YAML.safe_load_file(dir.join("meta.yml"))
      @markdown = ProblemMarkdown.new(read("problem.md"))
    end

    # @return [String]
    def slug = @meta.fetch("slug")

    # @return [Hash] attributes for Exercise#update!
    def attributes
      { kind: "problem", language: "ruby", category: @meta.fetch("category"), title: @meta.fetch("title"),
        position: @meta.fetch("position"), parts_count: parts.size, description_md: @markdown.intro,
        starter_code: read("starter.rb"), prelude_code: @test_helper, test_code: read("test.rb"),
        solution_code: read("solution.rb"), expected_code: nil, notes_md: @markdown.notes,
        code_path: @meta.fetch("code_path"), test_path: @meta.fetch("test_path") }
    end

    # @return [Hash{Integer=>String}] part number => markdown
    def parts = @markdown.parts

    private

    def read(name) = @dir.join(name).read
  end
end
