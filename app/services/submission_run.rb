# Executes one submission: runner call, verdict, progress, live page update.
# Invoked by RunSubmissionJob so the request thread never waits on the runner.
class SubmissionRun
  # @param submission [Submission] a pending submission
  # @param client [#run] a RunnerClient (or a fake with the same interface)
  def initialize(submission, client: RunnerClient.for(submission.exercise.language))
    @submission = submission
    @client = client
  end

  # @return [Submission] the finished submission
  def call
    @submission.running!
    broadcast
    record(@client.run(payload))
    broadcast
    @submission
  end

  private

  def payload = Checks.payload_for(@submission.exercise, @submission.code, part: @submission.part_number)

  def record(result)
    @submission.record!(result)
    ProgressRecorder.new(@submission).call unless result.unavailable?
  end

  def broadcast = SubmissionBroadcaster.new(@submission).call
end
