module DojoRunner
  # Rack endpoint: GET /health and POST /run. No other routes.
  class App
    MAX_BODY_BYTES = 1_000_000
    JSON_HEADERS = { "content-type" => "application/json" }.freeze

    # @param executor [Executor]
    def initialize(executor: Executor.new)
      @executor = executor
    end

    # @param env [Hash] Rack env
    # @return [Array] Rack response
    def call(env)
      request = Rack::Request.new(env)
      case [ request.request_method, request.path_info ]
      in [ "GET", "/health" ] then json(200, status: "ok", language: "ruby", sandboxed: DojoRunner.sandboxed?)
      in [ "POST", "/run" ] then run(request.body.read(MAX_BODY_BYTES + 1).to_s)
      else json(404, error: "not found")
      end
    end

    private

    def run(body)
      return json(413, error: "request too large") if body.bytesize > MAX_BODY_BYTES

      json(200, @executor.call(RunRequest.parse(body)))
    rescue InvalidRequest => e
      json(422, error: e.message)
    end

    def json(status, body) = [ status, JSON_HEADERS, [ JSON.generate(body) ] ]
  end
end
