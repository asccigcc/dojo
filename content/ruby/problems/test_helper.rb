require "minitest/autorun"

# PART unlocks tests progressively so later parts stay hidden while you work.
PART = Integer(ENV.fetch("PART", "1"))
TARGET = ENV.fetch("TARGET", "work")

def load_target(name)
  require_relative "../#{TARGET}/#{name}"
end

class Minitest::Test
  def part(number)
    skip("unlocks at part #{number}") if PART < number
  end
end
