require "rails_helper"

RSpec.describe "Exercises" do
  let(:user) { create(:user) }
  let(:problem) { create(:exercise, :problem, parts_count: 3, title: "Counter") }

  before { sign_in(user) }

  it "lists the catalog" do
    problem
    create(:exercise, title: "A1 · Count words")

    get exercises_path

    expect(response.body).to include("Counter", "A1 · Count words")
  end

  it "shows only the unlocked parts" do
    create(:progress, user:, exercise: problem, unlocked_part: 2)

    get exercise_path(problem)

    expect(response.body).to include("Part 1 text", "Part 2 text")
    expect(response.body).not_to include("Part 3 text")
  end

  it "loads the starter code, then the last submission's code" do
    get exercise_path(problem)
    expect(response.body).to include("class Counter")

    create(:submission, user:, exercise: problem, code: "class MyCounter; end", status: "failed")
    get exercise_path(problem)
    expect(response.body).to include("class MyCounter; end")
  end

  it "does not show other learners' submissions" do
    create(:submission, exercise: problem, code: "class SomeoneElse; end", status: "failed")

    get exercise_path(problem)

    expect(response.body).not_to include("SomeoneElse")
  end

  it "subscribes the page to its Turbo Stream" do
    get exercise_path(problem)

    expect(response.body).to include("turbo-cable-stream-source")
  end

  it "keeps the solution button disabled before any attempt" do
    get exercise_path(problem)

    expect(response.body).to include(I18n.t("solution_gate_component.locked_hint"))
    expect(response.body).not_to include(exercise_solution_path(problem))
  end

  it "returns 404 for an unknown exercise" do
    get exercise_path("nope")

    expect(response).to have_http_status(:not_found)
  end
end
