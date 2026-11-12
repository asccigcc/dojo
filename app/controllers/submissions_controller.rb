# Accepts a Run press, queues it, and streams back the results panel.
class SubmissionsController < ApplicationController
  def create
    exercise = Exercise.find_by!(slug: params[:exercise_slug])
    @submission = SubmissionLauncher.new(current_user, exercise, submitted_code).call
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("results", results_panel), status: response_status }
      format.html { redirect_to exercise_path(exercise), alert: @submission.errors.full_messages.to_sentence.presence }
    end
  end

  private

  def submitted_code = params.expect(submission: [ :code ])[:code]

  # Reloaded so an inline (test) or very fast job shows its finished state.
  def results_panel = ResultsPanelComponent.new(submission: @submission.persisted? ? @submission.reload : @submission)

  def response_status = @submission.persisted? ? :ok : :unprocessable_content
end
