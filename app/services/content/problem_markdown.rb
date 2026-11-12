module Content
  # Splits a kit problem file into its intro, numbered parts, and the
  # interviewer notes that stay hidden until the learner has tried it.
  class ProblemMarkdown
    SECTION_START = /^(?=## )/
    PART_HEADING = /\A## Part (\d+)\b/
    NOTES_HEADING = /\A## Interviewer notes.*\n/

    # @param text [String] the full problem.md
    def initialize(text)
      @sections = text.split(SECTION_START).map { |section| without_rule(section) }
    end

    # @return [String] everything before Part 1, minus the H1 title
    def intro = @sections.first.sub(/\A# .*\n/, "").strip

    # @return [Hash{Integer=>String}] part number => markdown (with its heading)
    def parts
      @sections.filter_map { |s| [ Integer(s[PART_HEADING, 1]), s ] if s.match?(PART_HEADING) }.to_h
    end

    # @return [String, nil] the interviewer notes body
    def notes = @sections.find { |s| s.match?(NOTES_HEADING) }&.sub(NOTES_HEADING, "")&.strip

    private

    def without_rule(section) = section.strip.sub(/\n+---\z/, "").strip
  end
end
