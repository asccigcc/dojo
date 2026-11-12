require "net/http"

# HTTP client for a language runner (see runners/<language>/). The web app
# never executes learner code itself; it only ships payloads here.
class RunnerClient
  OPEN_TIMEOUT = 2
  # Runs are capped at 10 s inside the runner; leave headroom for queueing.
  READ_TIMEOUT = 30
  FAILURES = [ SystemCallError, IOError, SocketError, Timeout::Error, Net::HTTPBadResponse, JSON::ParserError ].freeze

  attr_reader :url

  # @param language [String] e.g. "ruby"
  # @return [RunnerClient] pointed at that language's runner (url nil if unconfigured)
  def self.for(language)
    config = Rails.application.config_for(:runners)[language.to_sym]
    new(config&.dig(:url), language:)
  end

  # @param url [String, nil] base URL of the runner
  # @param language [String] only used in error messages
  def initialize(url, language: "ruby")
    @url = url
    @language = language
  end

  # @param payload [Hash] see Checks.payload_for
  # @return [RunResult]
  def run(payload)
    return unavailable(I18n.t("runner.unconfigured", language: @language)) if url.blank?

    parse(post(payload))
  rescue *FAILURES => e
    unavailable(I18n.t("runner.unreachable", language: @language, error: e.message))
  end

  private

  def post(payload)
    uri = URI.join(url, "/run")
    Net::HTTP.start(uri.host, uri.port, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
      http.post(uri.path, payload.to_json, "Content-Type" => "application/json")
    end
  end

  def parse(response)
    return RunResult.from_response(JSON.parse(response.body)) if response.is_a?(Net::HTTPSuccess)

    unavailable(I18n.t("runner.rejected", language: @language, code: response.code, body: response.body.to_s.first(500)))
  end

  def unavailable(message) = RunResult.unavailable(message)
end
