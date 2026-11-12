require_relative "test_helper"
load_target "06_patient_ledger"

class LedgerTest < Minitest::Test
  def setup
    @l = Ledger.new
    @l.charge("pat_a", "clm2", 2000, 10)
    @l.charge("pat_a", "clm1", 5000, 1)
    @l.charge("pat_b", "clm9", 1000, 1)
  end

  def test_part1_balance
    assert_equal 7000, @l.balance("pat_a")
    assert_equal 1000, @l.balance("pat_b")
    assert_equal 0, @l.balance("nobody")
  end

  def test_part2_pays_oldest_first
    part 2
    @l.pay("pat_a", 6000, 20)
    assert_equal [["clm2", 1000]], @l.open_charges("pat_a")
    assert_equal 1000, @l.balance("pat_a")
  end

  def test_part2_tie_by_insertion_order
    part 2
    @l.charge("pat_c", "x1", 100, 5)
    @l.charge("pat_c", "x2", 100, 5)
    @l.pay("pat_c", 150, 6)
    assert_equal [["x2", 50]], @l.open_charges("pat_c")
  end

  def test_part2_overpayment_credit
    part 2
    @l.pay("pat_b", 1500, 2)
    assert_equal(-500, @l.balance("pat_b"))
    assert_equal [], @l.open_charges("pat_b")
    @l.charge("pat_b", "clm10", 800, 3)
    assert_equal 300, @l.balance("pat_b")
    assert_equal [["clm10", 300]], @l.open_charges("pat_b")
  end

  def test_part3_adjust
    part 3
    assert_equal 1500, @l.adjust("clm1", 1500)
    assert_equal 5500, @l.balance("pat_a")
    assert_equal 3500, @l.adjust("clm1", 9999)
    assert_equal [["clm2", 2000]], @l.open_charges("pat_a")
    assert_equal 0, @l.adjust("nope", 10)
  end

  def test_part4_aging
    part 4
    @l.charge("pat_a", "clm3", 300, 50)
    @l.charge("pat_a", "clm4", 400, 95)
    @l.pay("pat_a", 1000, 95)
    # clm1 age 99 (4000 left), clm2 age 90, clm3 age 50, clm4 age 5
    expected = { "0-30" => 400, "31-60" => 300, "61-90" => 2000, "90+" => 4000 }
    assert_equal expected, @l.aging("pat_a", 100)
    assert_equal({ "0-30" => 0, "31-60" => 0, "61-90" => 0, "90+" => 0 }, @l.aging("nobody", 1))
  end
end
