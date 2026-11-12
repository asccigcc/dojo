# The catalog and the exercise page (editor, parts, results).
class ExercisesController < ApplicationController
  def index
    @catalog = Catalog.new(current_user)
  end

  def show
    @page = ExercisePage.new(current_user, Exercise.includes(:parts).find_by!(slug: params[:slug]))
  end
end
