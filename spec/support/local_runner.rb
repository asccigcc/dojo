require Rails.root.join("runners/ruby/lib/dojo_runner").to_s

# Test-only stand-in for RunnerClient that executes payloads with the real
# runner library on this machine (unsandboxed). Used to prove that imported
# reference solutions pass their own checks with the exact payloads the web
# app sends. Never used by the app itself.
class LocalRunner
  def run(payload)
    request = DojoRunner::RunRequest.new(JSON.parse(payload.to_json))
    RunResult.from_response(JSON.parse(DojoRunner::Executor.new.call(request).to_json))
  end
end
