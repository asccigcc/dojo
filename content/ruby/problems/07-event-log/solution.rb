class EventLog
  Event = Struct.new(:ts, :member, :type)

  def initialize
    @events = []
  end

  def ingest(line)
    fields = line.split(",", -1).map(&:strip)
    return false unless fields.size == 3

    ts, member, type = fields
    return false unless ts.match?(/\A\d+\z/) && !member.empty? && !type.empty?

    @events << Event.new(Integer(ts), member, type)
    true
  end

  def count_by_type = @events.map(&:type).tally

  def top_members(k)
    @events.map(&:member).tally.sort_by { |member, count| [-count, member] }.first(k).map(&:first)
  end

  def sessions(member, gap)
    times = @events.select { |e| e.member == member }.map(&:ts).sort
    return 0 if times.empty?

    1 + times.each_cons(2).count { |a, b| b - a > gap }
  end

  def busiest_window(window)
    times = @events.map(&:ts).sort
    return nil if times.empty?

    right = 0
    best = nil
    times.each_with_index do |start, left|
      right += 1 while right < times.size && times[right] < start + window
      best = [start, right - left] if best.nil? || right - left > best[1]
    end
    best
  end
end
