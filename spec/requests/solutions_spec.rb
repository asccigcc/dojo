require "rails_helper"

RSpec.describe "Solutions" do
  let(:user) { create(:user) }
  let(:problem) { create(:exercise, :problem, solution_code: "class Counter; SECRET = 1; end") }

  before { sign_in(user) }

  it "refuses to reveal the solution before a real attempt" do
    get exercise_solution_path(problem)

    expect(response).to have_http_status(:forbidden)
  end

  it "ignores another learner's attempts" do
    create(:submission, exercise: problem)

    get exercise_solution_path(problem)

    expect(response).to have_http_status(:forbidden)
  end

  it "reveals the solution and interviewer notes after one submission" do
    create(:submission, user:, exercise: problem, status: "failed")

    get exercise_solution_path(problem)

    expect(response.body).to include("SECRET = 1", "Ask about edge cases.")
  end
end
