require_relative "test_helper"
load_target "03_coverage_windows"

class CoverageBookTest < Minitest::Test
  def setup
    @b = CoverageBook.new
  end

  def test_part1_covered
    @b.add("m1", 1, 10)
    @b.add("m1", 20, 30)
    assert @b.covered?("m1", 1)
    assert @b.covered?("m1", 10)
    refute @b.covered?("m1", 15)
    assert @b.covered?("m1", 30)
    refute @b.covered?("m2", 5)
  end

  def test_part2_merges_overlap_and_adjacent
    part 2
    @b.add("m1", 15, 20)
    @b.add("m1", 1, 10)
    @b.add("m1", 11, 12)
    @b.add("m1", 18, 25)
    @b.add("m1", 40, 41)
    assert_equal [[1, 12], [15, 25], [40, 41]], @b.periods("m1")
    assert_equal [], @b.periods("nobody")
  end

  def test_part2_contained_period
    part 2
    @b.add("m1", 1, 100)
    @b.add("m1", 10, 20)
    assert_equal [[1, 100]], @b.periods("m1")
  end

  def test_part3_gaps
    part 3
    @b.add("m1", 5, 10)
    @b.add("m1", 20, 25)
    assert_equal [[1, 4], [11, 19], [26, 30]], @b.gaps("m1", 1, 30)
    assert_equal [[11, 19]], @b.gaps("m1", 7, 22)
    assert_equal [], @b.gaps("m1", 5, 10)
    assert_equal [[1, 3]], @b.gaps("nobody", 1, 3)
  end

  def test_part4_primary_payer
    part 4
    @b.add("m1", 1, 30, payer: "Medicaid", priority: 2)
    @b.add("m1", 10, 20, payer: "Aetna", priority: 1)
    @b.add("m1", 25, 40, payer: "Humana", priority: 2)
    assert_equal "Medicaid", @b.primary_payer("m1", 5)
    assert_equal "Aetna", @b.primary_payer("m1", 15)
    assert_equal "Medicaid", @b.primary_payer("m1", 27)
    assert_equal "Humana", @b.primary_payer("m1", 35)
    assert_nil @b.primary_payer("m1", 50)
  end

  def test_part4_defaults_still_work
    part 4
    @b.add("m1", 1, 5)
    assert_equal "UNKNOWN", @b.primary_payer("m1", 3)
    assert_equal [[1, 5]], @b.periods("m1")
  end
end
