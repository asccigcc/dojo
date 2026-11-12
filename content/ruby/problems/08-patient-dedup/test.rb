require_relative "test_helper"
load_target "08_patient_dedup"

# Each test builds its own data so earlier parts keep passing after later parts land.
class DedupTest < Minitest::Test
  def setup
    @d = Dedup.new
  end

  def add_marys
    @d.add(3, first: "Mary ", last: "O'Neil", dob: "1980-02-01")
    @d.add(1, first: "mary", last: "ONEIL", dob: "1980-02-01")
    @d.add(4, first: "Mary", last: "Oneil", dob: "1999-09-09")
  end

  def test_part1_name_groups
    add_marys
    assert_equal [[1, 3]], @d.duplicate_groups
  end

  def test_part1_no_duplicates
    @d.add(1, first: "Ann", last: "Lee", dob: "1990-01-01")
    assert_equal [], @d.duplicate_groups
  end

  def test_part2_phone_and_transitive
    part 2
    add_marys
    @d.add(2, first: "Maria", last: "Smith", dob: "1980-02-01", phone: "1-501-555-0100")
    @d.add(5, first: "Zed", last: "Zee", dob: "1980-02-01", phone: "(501) 555-0100")
    @d.add(6, first: "Short", last: "Phone", dob: "1980-02-01", phone: "555-0100")
    @d.add(7, first: "Other", last: "Dob", dob: "2001-01-01", phone: "5015550100")
    assert_equal [[1, 3], [2, 5]], @d.duplicate_groups
    @d.add(8, first: "MARY", last: "oneil", dob: "1980-02-01", phone: "501.555.0100")
    assert_equal [[1, 2, 3, 5, 8]], @d.duplicate_groups
  end

  def test_part3_golden_record_ties_go_to_lowest_id
    part 3
    @d.add(3, first: "Mary ", last: "O'Neil", dob: "1980-02-01", phone: "(501) 555-0100")
    @d.add(1, first: "mary", last: "ONEIL", dob: "1980-02-01")
    @d.add(2, first: "Mary", last: "Smith", dob: "1980-02-01", phone: "1-501-555-0100")
    expected = { first: "mary", last: "ONEIL", dob: "1980-02-01", phone: "1-501-555-0100" }
    assert_equal expected, @d.golden_record([3, 2, 1])
  end

  def test_part3_golden_record_majority
    part 3
    add_marys
    @d.add(8, first: "Mary", last: "Oneil", dob: "1980-02-01", phone: "")
    @d.add(9, first: "Mary", last: "Oneil", dob: "1980-02-01")
    record = @d.golden_record([1, 3, 8, 9])
    assert_equal ["Mary", "Oneil", nil], record.values_at(:first, :last, :phone)
  end

  def test_part4_nicknames
    part 4
    @d.add(5, first: "Bob", last: "Ray", dob: "1970-01-01")
    @d.add(6, first: "Robert", last: "Ray", dob: "1970-01-01")
    @d.add(7, first: "Rob", last: "Ray", dob: "1970-01-01")
    @d.add(8, first: "Bill", last: "Ray", dob: "1970-01-01")
    assert_equal [[5, 6, 7]], @d.duplicate_groups
  end
end
