require_relative "test_helper"
load_target "04_care_team_assignment"

class AssignerTest < Minitest::Test
  def setup
    @a = Assigner.new
  end

  def test_part1_round_robin
    %w[ana ben cy].each { |n| @a.add_nurse(n) }
    assert_equal %w[ana ben cy ana], %w[t1 t2 t3 t4].map { |t| @a.assign(t) }
    assert_equal %w[t1 t4], @a.tasks_for("ana")
    assert_equal [], Assigner.new.tap { |x| x.add_nurse("z") }.tasks_for("z")
  end

  def test_part2_capacity_and_waiting
    part 2
    @a.add_nurse("ana", capacity: 1)
    @a.add_nurse("ben", capacity: 2)
    assert_equal "ana", @a.assign("t1")
    assert_equal "ben", @a.assign("t2")
    assert_equal "ben", @a.assign("t3")
    assert_nil @a.assign("t4")
    assert_nil @a.assign("t5")
    assert_equal %w[t4 t5], @a.waiting
    assert @a.complete("t1")
    assert_equal %w[t4], @a.tasks_for("ana")
    assert_equal %w[t5], @a.waiting
    refute @a.complete("nope")
  end

  def test_part2_complete_drains_multiple
    part 2
    @a.add_nurse("ana", capacity: 2)
    @a.assign("t1"); @a.assign("t2"); @a.assign("t3"); @a.assign("t4")
    assert_equal %w[t3 t4], @a.waiting
    @a.complete("t1")
    @a.complete("t2")
    assert_equal %w[t3 t4], @a.tasks_for("ana")
    assert_equal [], @a.waiting
  end

  def test_part3_off_shift_reassigns
    part 3
    %w[ana ben cy].each { |n| @a.add_nurse(n) }
    %w[t1 t2 t3 t4].each { |t| @a.assign(t) }
    @a.off_shift("ana")
    assert_equal %w[t2 t1], @a.tasks_for("ben")
    assert_equal %w[t3 t4], @a.tasks_for("cy")
    assert_equal "ben", @a.assign("t5")
  end

  def test_part3_off_shift_to_waiting
    part 3
    @a.add_nurse("ana")
    @a.add_nurse("ben", capacity: 1)
    @a.assign("t1"); @a.assign("t2"); @a.assign("t3")
    @a.off_shift("ana")
    assert_equal %w[t2], @a.tasks_for("ben")
    assert_equal %w[t1 t3], @a.waiting
  end

  def test_part4_urgent_jumps_queue
    part 4
    @a.add_nurse("ana", capacity: 1)
    @a.assign("t1")
    @a.assign("t2")
    @a.assign("t3", priority: :urgent)
    @a.assign("t4", priority: :urgent)
    @a.assign("t5")
    assert_equal %w[t3 t4 t2 t5], @a.waiting
    @a.complete("t1")
    assert_equal %w[t3], @a.tasks_for("ana")
  end
end
