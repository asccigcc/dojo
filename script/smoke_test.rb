#!/usr/bin/env ruby
# End-to-end smoke test against a RUNNING Dojo (bin/dev or docker compose up).
#
#   ruby script/smoke_test.rb [http://127.0.0.1:3000]
#
# Signs in, runs a failing and a passing submission, checks that part 2
# unlocks and the review date is set, then sends hostile snippets that the
# runner must contain. Prints one line per check; exits 1 if any fail.
require "net/http"
require "uri"
require "cgi"

# Minimal cookie-keeping HTTP session that speaks Rails CSRF.
class SmokeSession
  def initialize(base)
    @base = URI(base)
    @cookies = {}
  end

  def get(path) = request(Net::HTTP::Get.new(path))

  def post(path, form, accept: "text/vnd.turbo-stream.html, text/html")
    req = Net::HTTP::Post.new(path, "Accept" => accept)
    req.set_form_data(form.merge("authenticity_token" => @csrf))
    request(req)
  end

  private

  def request(req)
    req["Cookie"] = @cookies.map { |k, v| "#{k}=#{v}" }.join("; ")
    res = Net::HTTP.start(@base.host, @base.port, read_timeout: 30) { |http| http.request(req) }
    remember(res)
    res
  end

  def remember(res)
    Array(res.get_fields("set-cookie")).each { |c| k, v = c.split(";").first.split("=", 2); @cookies[k] = v }
    @csrf = CGI.unescapeHTML(res.body[/name="csrf-token" content="([^"]+)"/, 1]) if res.body&.include?("csrf-token")
  end
end

class SmokeTest
  WARMUP = "/exercises/warmup-a01"
  PROBLEM = "/exercises/01-refill-tracker"

  def initialize(base)
    @http = SmokeSession.new(base)
    @failures = 0
  end

  def call
    sign_in
    problem_flow
    warmup_flow
    hostile_snippets
    puts(@failures.zero? ? "ALL CHECKS PASSED" : "#{@failures} CHECK(S) FAILED")
    exit(@failures.zero? ? 0 : 1)
  end

  private

  def check(name, ok, detail = nil)
    @failures += 1 unless ok
    puts "#{ok ? 'PASS' : 'FAIL'} #{name}#{" -- #{detail}" if detail && !ok}"
  end

  def sign_in
    @http.get("/session/new")
    res = @http.post("/session", { "session[name]" => "smoke-#{Time.now.to_i}" }, accept: "text/html")
    check("sign in with a username", res.is_a?(Net::HTTPRedirection))
    home = @http.get("/").body
    check("Today shows a warm-up and a problem", home.include?("Warm-up") && home.include?("Problem") && home.scan("btn-primary").size >= 2)
  end

  def problem_flow
    @http.get(PROBLEM)
    failed = run(PROBLEM, "class RefillTracker\nend\n")
    check("failing submission reports Failed", failed.include?("Failed"), failed[0, 300])
    passed = run(PROBLEM, solution)
    check("passing submission reports Passed", passed.include?("Passed"), passed[0, 300])
    check("part 2 unlocks after part 1 passes", @http.get(PROBLEM).body.include?("Part 2 of 4"))
  end

  def warmup_flow
    @http.get(WARMUP)
    result = run(WARMUP, "WORDS.tally")
    check("warm-up answer passes", result.include?("Passed"), result[0, 300])
    check("review date advanced (Done today shows next review)", @http.get("/").body.include?("next review"))
  end

  def hostile_snippets
    {
      "loop {} times out" => [ "loop {}", ->(r) { r.include?("Timed out") } ],
      "File.write(\"/app/x\") fails" => [ "File.write(\"/app/x\", \"\")", ->(r) { r.include?("Error") && r.match?(/Errno::E(ROFS|ACCES)/) } ],
      "outbound HTTP fails" => [ "require \"net/http\"\nNet::HTTP.get(URI(\"http://example.com\"))", ->(r) { r.include?("Error") || r.include?("Timed out") } ],
      "fork bomb is contained" => [ "fork while true", ->(r) { !r.include?("Passed") } ],
      "giant puts is truncated" => [ "puts \"x\" * 5_000_000\n1", ->(r) { r.include?("output truncated") } ]
    }.each do |name, (code, ok)|
      @http.get(WARMUP)
      result = run(WARMUP, code)
      check(name, ok.call(result), summary(result))
      puts "     #{summary(result)}"
    end
    check("web app still healthy after hostile runs", @http.get("/up").is_a?(Net::HTTPSuccess))
  end

  # Submits code, then polls the page until the results panel shows a verdict.
  def run(path, code)
    @http.post("#{path}/submissions", { "submission[code]" => code })
    60.times do
      panel = results_panel(@http.get(path).body)
      return panel unless panel.include?("animate-spin")

      sleep 0.5
    end
    "still running after 30s"
  end

  def summary(panel)
    text = panel.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").sub(/\A Results /, "")
    text.length > 220 ? "#{text[0, 220]}..." : text
  end

  def results_panel(html) = CGI.unescapeHTML(html[%r{<section id="results".*?</section>}m].to_s)

  def solution = File.read(File.expand_path("../content/ruby/problems/01-refill-tracker/solution.rb", __dir__))
end

SmokeTest.new(ARGV.fetch(0, "http://127.0.0.1:3000")).call
