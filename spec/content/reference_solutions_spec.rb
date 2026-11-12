require "rails_helper"

# Proves every imported reference answer passes the check a learner's code
# would get, using the real runner harness.
RSpec.describe "Imported content checks" do
  before(:all) { Content::Importer.new.call }
  after(:all) { Exercise.delete_all }

  let(:runner) { LocalRunner.new }

  def check(exercise, code, part: exercise.parts_count)
    runner.run(Checks.payload_for(exercise, code, part:))
  end

  Content::Importer.new.warmup_sources.each do |source|
    it "warm-up #{source.slug}: the reference answer passes" do
      result = check(Exercise.find_by!(slug: source.slug), source.attributes[:solution_code])

      expect(result.status).to eq("passed"), -> { result.failures.inspect + result.stderr }
    end
  end

  Content::Importer.new.problem_sources.each do |source|
    it "problem #{source.slug}: the reference solution passes every part cumulatively" do
      exercise = Exercise.find_by!(slug: source.slug)
      statuses = (1..exercise.parts_count).map { |part| check(exercise, exercise.solution_code, part:).status }

      expect(statuses).to all(eq("passed"))
    end

    it "problem #{source.slug}: the starter loads and fails part 1 (not a load error)" do
      exercise = Exercise.find_by!(slug: source.slug)
      result = check(exercise, exercise.starter_code, part: 1)

      expect(result.status).to eq("failed"), -> { result.stderr }
    end
  end
end
