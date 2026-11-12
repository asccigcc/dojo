require_relative "test_helper"
load_target "02_kv_store_transactions"

class StoreTest < Minitest::Test
  def setup
    @s = Store.new
  end

  def test_part1_set_get_delete
    @s.set("a", "x")
    assert_equal "x", @s.get("a")
    assert_nil @s.get("b")
    assert @s.delete("a")
    refute @s.delete("a")
    assert_nil @s.get("a")
  end

  def test_part1_overwrite
    @s.set("a", "x")
    @s.set("a", "y")
    assert_equal "y", @s.get("a")
  end

  def test_part2_count
    part 2
    @s.set("a", "high")
    @s.set("b", "high")
    @s.set("c", "low")
    assert_equal 2, @s.count("high")
    @s.set("b", "low")
    assert_equal 1, @s.count("high")
    @s.delete("a")
    assert_equal 0, @s.count("high")
    assert_equal 0, @s.count("nope")
  end

  def test_part3_nested_rollback
    part 3
    @s.set("a", 10)
    @s.begin_tx
    @s.set("a", 20)
    @s.begin_tx
    @s.delete("a")
    assert_nil @s.get("a")
    assert @s.rollback
    assert_equal 20, @s.get("a")
    assert @s.rollback
    assert_equal 10, @s.get("a")
    refute @s.rollback
  end

  def test_part3_commit_closes_all
    part 3
    @s.begin_tx
    @s.set("a", 1)
    @s.begin_tx
    @s.set("b", 2)
    assert @s.commit
    refute @s.rollback
    assert_equal [1, 2], [@s.get("a"), @s.get("b")]
    refute @s.commit
  end

  def test_part3_rollback_restores_counts_and_new_keys
    part 3
    @s.set("a", "high")
    @s.begin_tx
    @s.set("a", "low")
    @s.set("a", "mid")
    @s.set("new", "high")
    assert_equal 1, @s.count("high")
    @s.rollback
    assert_equal "high", @s.get("a")
    assert_nil @s.get("new")
    assert_equal 1, @s.count("high")
    assert_equal 0, @s.count("mid")
  end

  def test_part4_prefix_scan
    part 4
    @s.set("m2:risk", "low")
    @s.set("m1:risk", "high")
    @s.set("m1:plan", "ppo")
    @s.set("x", 1)
    assert_equal %w[m1:plan m1:risk], @s.keys_with_prefix("m1:")
    @s.begin_tx
    @s.delete("m1:plan")
    assert_equal %w[m1:risk], @s.keys_with_prefix("m1:")
    @s.rollback
    assert_equal %w[m1:plan m1:risk m2:risk], @s.keys_with_prefix("m")
  end
end
