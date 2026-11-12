require_relative "test_helper"
load_target "07_event_log"

class EventLogTest < Minitest::Test
  LINES = [
    "100,m1,call_completed",
    " 105 , m2 , sms_sent ",
    "110,m1,sms_sent",
    "bad line",
    "abc,m3,call_completed",
    "120,,call_completed",
    "130,m3,call_completed,extra",
    "400,m1,call_completed",
    "90,m2,call_completed"
  ].freeze

  def setup
    @log = EventLog.new
    @results = LINES.map { |line| @log.ingest(line) }
  end

  def test_part1_validation
    assert_equal [true, true, true, false, false, false, false, true, true], @results
  end

  def test_part1_count_by_type
    assert_equal({ "call_completed" => 3, "sms_sent" => 2 }, @log.count_by_type)
  end

  def test_part2_top_members
    part 2
    @log.ingest("500,m0,sms_sent")
    @log.ingest("501,m0,sms_sent")
    assert_equal %w[m1 m0], @log.top_members(2)
    assert_equal %w[m1 m0 m2], @log.top_members(10)
  end

  def test_part3_sessions
    part 3
    assert_equal 2, @log.sessions("m1", 30)    # 100,110 | 400
    assert_equal 1, @log.sessions("m1", 300)
    assert_equal 1, @log.sessions("m2", 15)    # 90,105 diff 15 is not > 15
    assert_equal 2, @log.sessions("m2", 14)
    assert_equal 0, @log.sessions("ghost", 10)
  end

  def test_part4_busiest_window
    part 4
    assert_equal [90, 4], @log.busiest_window(21)   # 90,100,105,110
    assert_equal [90, 3], @log.busiest_window(16)   # 90,100,105 (tie with 100,105,110 -> earliest)
    assert_equal [90, 1], @log.busiest_window(1)
    assert_nil EventLog.new.busiest_window(10)
  end
end
