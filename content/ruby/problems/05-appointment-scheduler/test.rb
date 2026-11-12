require_relative "test_helper"
load_target "05_appointment_scheduler"

class SchedulerTest < Minitest::Test
  def setup
    @s = Scheduler.new
  end

  def test_part1_book_overlap_and_ids
    assert_equal "A1", @s.book("lee", 540, 30)
    assert_nil @s.book("lee", 555, 30)
    assert_nil @s.book("lee", 500, 41)
    assert_equal "A2", @s.book("lee", 570, 30)
    assert_equal "A3", @s.book("lee", 510, 30)
    assert_equal "A4", @s.book("kim", 540, 30)
  end

  def test_part1_cancel_frees_slot
    id = @s.book("lee", 540, 30)
    assert @s.cancel(id)
    refute @s.cancel(id)
    refute @s.cancel("A99")
    assert_equal "A2", @s.book("lee", 540, 30)
  end

  def test_part2_schedule_sorted
    part 2
    @s.book("lee", 600, 30)
    @s.book("lee", 540, 15)
    id = @s.book("lee", 560, 20)
    @s.cancel(id)
    assert_equal [[540, 555], [600, 630]], @s.schedule("lee")
    assert_equal [], @s.schedule("nobody")
  end

  def test_part3_next_available
    part 3
    @s.book("lee", 540, 30)  # 540-570
    @s.book("lee", 580, 20)  # 580-600
    assert_equal 520, @s.next_available("lee", 520, 20, 1020)
    assert_equal 530, @s.next_available("lee", 530, 10, 1020)
    assert_equal 570, @s.next_available("lee", 535, 10, 1020)
    assert_equal 600, @s.next_available("lee", 530, 15, 1020)
    assert_nil @s.next_available("lee", 530, 30, 620)
    assert_equal 0, @s.next_available("kim", 0, 60, 60)
  end

  def test_part4_book_any_fewest
    part 4
    @s.book("lee", 600, 30)
    @s.book("lee", 700, 30)
    @s.book("kim", 800, 30)
    assert_equal ["park", "A4"], @s.book_any(%w[lee kim park], 540, 30)
    assert_equal ["kim", "A5"], @s.book_any(%w[lee kim park], 540, 30)
    assert_equal ["lee", "A6"], @s.book_any(%w[lee kim park], 540, 30)
    assert_nil @s.book_any(%w[lee kim park], 550, 10)
  end
end
