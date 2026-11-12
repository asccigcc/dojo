module DojoRunner
  # Runs one validated request: workspace in, report out.
  class Executor
    # @param sandbox [Sandbox]
    # @param tmp_root [String] where workspaces are created
    def initialize(sandbox: Sandbox.new, tmp_root: Dir.tmpdir)
      @sandbox = sandbox
      @tmp_root = tmp_root
    end

    # @param request [RunRequest]
    # @return [Hash] see Report#to_h
    def call(request)
      Workspace.open(request.files, root: @tmp_root) do |workspace|
        outcome = @sandbox.run(Command.for(request), dir: workspace.dir,
          env: env_for(request, workspace), timeout_s: request.timeout_s)
        Report.new(outcome, workspace.read_result).to_h
      end
    end

    private

    def env_for(request, workspace)
      request.env.merge("DOJO_RESULT_PATH" => workspace.result_path, "HOME" => workspace.dir,
        "TMPDIR" => workspace.dir, "PATH" => Sandbox::BASE_PATH, "LANG" => "C.UTF-8")
    end
  end
end
