require "set"

class Referrals
  NONE = Set.new.freeze

  def initialize
    @enrolled = Set.new
    @referred = Hash.new { |h, from| h[from] = Set.new }  # from => Set of people referred
  end

  def enroll(member) = !@enrolled.add?(member).nil?

  def enrolled?(member) = @enrolled.include?(member)

  def count = @enrolled.size

  def refer(from, to)
    return :unknown_referrer unless enrolled?(from)
    return :already_enrolled if enrolled?(to)
    return :duplicate unless @referred[from].add?(to)

    :ok
  end

  def unique_referrals(from) = referred_by(from).sort

  # Breadth-first walk; the visited set makes loops harmless.
  def network(member)
    visited = Set[member]
    queue = [member]
    while (current = queue.shift)
      referred_by(current).each { |person| queue << person if visited.add?(person) }
    end
    (visited - [member]).sort
  end

  def import(from, to) = @referred[from] << to

  def common_referrers(a, b)
    @referred.select { |_, people| people.include?(a) && people.include?(b) }.keys.sort
  end

  private

  # fetch avoids the default block, so reads never create keys.
  def referred_by(member) = @referred.fetch(member, NONE)
end
