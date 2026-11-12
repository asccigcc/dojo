# Warm-up checker. Evaluates prelude.rb (shared data) and then answer.rb in
# one isolated binding, takes the value of the answer's last expression, and
# compares it with expected.rb using `expected == actual`.
require "json"
require "set"

# Holds the harness state in a module so user code cannot clobber it by
# reusing a local variable name.
module DojoExpression
  RESULT_PATH = ENV.delete("DOJO_RESULT_PATH").freeze
  INSPECT_LIMIT = 2_000
  COUNTS = { runs: 1, assertions: 1, failures: 0, errors: 0, skips: 0 }.freeze

  def self.run
    scope = TOPLEVEL_BINDING.receiver.send(:dojo_fresh_binding)
    evaluate("prelude.rb", scope)
    actual = evaluate("answer.rb", scope)
    verdict(evaluate("expected.rb", TOPLEVEL_BINDING.receiver.send(:dojo_fresh_binding)), actual)
  rescue Exception => e # rubocop:disable Lint/RescueException -- SyntaxError and exit must be reported
    error(e)
  end

  def self.evaluate(name, scope)
    eval(File.exist?(name) ? File.read(name) : "", scope, name, 1) # rubocop:disable Security/Eval
  end

  def self.verdict(expected, actual)
    return write(tests: COUNTS, failures: [], actual: show(actual)) if (expected == actual) == true

    message = "Expected: #{show(expected)}\n  Actual: #{show(actual)}"
    write(tests: COUNTS.merge(failures: 1), failures: [ { name: "answer", kind: "failure", message: } ])
  end

  def self.error(exception)
    failure = { name: "answer", kind: "error", message: "#{exception.class}: #{exception.message}"[0, INSPECT_LIMIT],
      location: exception.backtrace.to_a.grep(/answer\.rb/).first }
    write(error: true, tests: COUNTS.merge(assertions: 0, errors: 1), failures: [ failure ])
  end

  def self.show(value) = (value.inspect rescue "#<uninspectable>").to_s[0, INSPECT_LIMIT]

  def self.write(verdict) = File.write(RESULT_PATH, JSON.generate(verdict))
end

# A binding with `self` = main but no locals from this file.
def dojo_fresh_binding = binding

DojoExpression.run
