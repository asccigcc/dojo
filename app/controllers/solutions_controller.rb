# Reveals the reference solution and notes, but only after a real attempt.
class SolutionsController < ApplicationController
  def show
    @exercise = Exercise.find_by!(slug: params[:exercise_slug])
    head :forbidden unless current_user.submissions.exists?(exercise: @exercise)
  end
end
