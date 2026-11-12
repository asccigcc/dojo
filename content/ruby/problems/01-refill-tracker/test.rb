require_relative "test_helper"
load_target "01_refill_tracker"

class RefillTrackerTest < Minitest::Test
  def setup
    @t = RefillTracker.new
    @t.add_prescription("rx1", "pat_a", "metformin", 30, 3)
    @t.add_prescription("rx2", "pat_a", "lisinopril", 90, 1)
    @t.add_prescription("rx3", "pat_b", "atorvastatin", 30, 2)
  end

  def test_part1_fill_uses_a_refill
    assert_equal :ok, @t.fill("rx1", 0)
    assert_equal 2, @t.remaining("rx1")
  end

  def test_part1_no_refills_left
    assert_equal :ok, @t.fill("rx2", 0)
    assert_equal :no_refills, @t.fill("rx2", 200)
    assert_equal 0, @t.remaining("rx2")
  end

  def test_part2_next_due
    part 2
    assert_nil @t.next_due("rx1")
    @t.fill("rx1", 5)
    assert_equal 35, @t.next_due("rx1")
  end

  def test_part3_overdue_sorted_and_filtered
    part 3
    @t.fill("rx1", 10)  # due 40
    @t.fill("rx3", 0)   # due 30
    @t.fill("rx2", 0)   # due 90, but no fills left
    assert_equal %w[rx3 rx1], @t.overdue(100)
    assert_equal %w[rx3], @t.overdue(35)
    assert_equal [], @t.overdue(30)
  end

  def test_part3_overdue_tie_breaks_by_id
    part 3
    @t.add_prescription("rx0", "pat_c", "metformin", 30, 2)
    @t.fill("rx1", 0)
    @t.fill("rx0", 0)
    assert_equal %w[rx0 rx1], @t.overdue(50)
  end

  def test_part4_too_early
    part 4
    @t.fill("rx1", 0)
    assert_equal :too_early, @t.fill("rx1", 22)  # ceil(22.5) = 23
    assert_equal 2, @t.remaining("rx1")
    assert_equal :ok, @t.fill("rx1", 23)
  end

  def test_part4_patient_summary
    part 4
    @t.fill("rx1", 0)
    assert_equal({ "metformin" => 2, "lisinopril" => 1 }, @t.patient_summary("pat_a"))
    assert_equal({}, @t.patient_summary("nobody"))
  end
end
