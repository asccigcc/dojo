module Content
  # Loads the versioned content files into the database. Idempotent: upserts
  # by slug, so it runs on every boot and from db:seed. It never deletes an
  # exercise, because that would delete the learner's history with it.
  class Importer
    DEFAULT_ROOT = Rails.root.join("content/ruby")

    # @param root [Pathname] the language's content directory
    def initialize(root: DEFAULT_ROOT)
      @root = root
    end

    # @return [Hash{Symbol=>Integer}] how many problems and warm-ups were loaded
    def call
      Exercise.transaction { (problem_sources + warmup_sources).each { |source| upsert(source) } }
      { problems: problem_sources.size, warmups: warmup_sources.size }
    end

    # @return [Array<WarmupSource>]
    def warmup_sources
      @warmup_sources ||= @root.glob("warmups/*/*.yml").sort.map { |path| WarmupSource.new(path, data_code) }
    end

    # @return [Array<ProblemSource>]
    def problem_sources
      @problem_sources ||= @root.glob("problems/*/meta.yml").sort.map { |meta| ProblemSource.new(meta.dirname, test_helper) }
    end

    private

    def upsert(source)
      exercise = Exercise.find_or_initialize_by(slug: source.slug)
      exercise.update!(source.attributes)
      PartSync.new(exercise, source.parts).call
    end

    def data_code = @root.join("warmups/data.rb").read

    def test_helper = @root.join("problems/test_helper.rb").read
  end
end
