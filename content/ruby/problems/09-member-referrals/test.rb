require_relative "test_helper"
load_target "09_member_referrals"

class ReferralsTest < Minitest::Test
  def setup
    @r = Referrals.new
  end

  def build_network
    %w[ana ben].each { |m| @r.enroll(m) }
    @r.refer("ana", "cy")
    @r.enroll("cy")
    @r.refer("cy", "eve")
    @r.refer("cy", "fay")
    @r.enroll("eve")
    @r.refer("eve", "gus")
    @r.refer("ben", "fay")
  end

  def test_part1_enroll
    assert @r.enroll("ana")
    refute @r.enroll("ana")
    assert @r.enroll("ben")
    assert @r.enrolled?("ana")
    refute @r.enrolled?("cy")
    assert_equal 2, @r.count
  end

  def test_part2_refer_rules
    part 2
    %w[ana ben].each { |m| @r.enroll(m) }
    assert_equal :ok, @r.refer("ana", "cy")
    assert_equal :duplicate, @r.refer("ana", "cy")
    assert_equal :unknown_referrer, @r.refer("dee", "eve")
    assert_equal :unknown_referrer, @r.refer("dee", "ana")
    assert_equal :already_enrolled, @r.refer("ana", "ben")
    assert_equal :ok, @r.refer("ana", "dan")
    refute @r.enrolled?("cy")
  end

  def test_part2_unique_referrals
    part 2
    @r.enroll("ana")
    @r.refer("ana", "zoe")
    @r.refer("ana", "cy")
    @r.refer("ana", "zoe")
    assert_equal %w[cy zoe], @r.unique_referrals("ana")
    assert_equal [], @r.unique_referrals("nobody")
  end

  def test_part3_network
    part 3
    build_network
    assert_equal %w[cy eve fay gus], @r.network("ana")
    assert_equal %w[fay], @r.network("ben")
    assert_equal [], @r.network("gus")
    assert_equal [], @r.network("stranger")
  end

  def test_part4_import_with_loops
    part 4
    build_network
    @r.import("gus", "ana")
    @r.import("zed", "zed")
    assert_equal %w[cy eve fay gus], @r.network("ana")
    assert_equal %w[ana cy eve fay], @r.network("gus")
    assert_equal [], @r.network("zed")
  end

  def test_part4_common_referrers
    part 4
    build_network
    @r.import("ben", "eve")
    assert_equal %w[ben cy], @r.common_referrers("eve", "fay")
    assert_equal [], @r.common_referrers("cy", "gus")
  end
end
