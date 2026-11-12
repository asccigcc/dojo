class CoverageBook
  Period = Struct.new(:start, :finish, :payer, :priority)

  def initialize
    @periods = Hash.new { |h, member| h[member] = [] }
  end

  def add(member, start, finish, payer: "UNKNOWN", priority: 99)
    @periods[member] << Period.new(start, finish, payer, priority)
  end

  def covered?(member, day) = covering(member, day).any?

  def periods(member)
    sorted = @periods.fetch(member, []).map { |p| [p.start, p.finish] }.sort
    sorted.each_with_object([]) do |(start, finish), merged|
      if merged.any? && start <= merged.last[1] + 1
        merged.last[1] = [merged.last[1], finish].max
      else
        merged << [start, finish]
      end
    end
  end

  def gaps(member, from, to)
    cursor = from
    result = []
    periods(member).each do |start, finish|
      result << [cursor, [start - 1, to].min] if start > cursor && cursor <= to
      cursor = [cursor, finish + 1].max
    end
    result << [cursor, to] if cursor <= to
    result
  end

  def primary_payer(member, day)
    # min_by keeps the first minimum, so ties go to the earliest-added period.
    covering(member, day).min_by(&:priority)&.payer
  end

  private

  def covering(member, day)
    @periods.fetch(member, []).select { |p| p.start <= day && day <= p.finish }
  end
end
