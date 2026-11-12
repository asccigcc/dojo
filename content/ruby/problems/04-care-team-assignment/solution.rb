# Decisions agreed with the "interviewer":
# - Rotation is an index into on-shift nurses; it advances past whoever got the task.
# - Completing a task does not change whose turn it is.
class Assigner
  def initialize
    @nurses = []                                   # rotation order
    @capacity = {}
    @open = Hash.new { |h, nurse| h[nurse] = [] }  # nurse => open task ids
    @owner = {}                                    # task id => nurse
    @queues = { urgent: [], routine: [] }
    @next = 0
  end

  def add_nurse(name, capacity: Float::INFINITY)
    @nurses << name
    @capacity[name] = capacity
  end

  def assign(task, priority: :routine)
    nurse = next_with_room
    return enqueue(task, priority) unless nurse

    @open[nurse] << task
    @owner[task] = nurse
  end

  def tasks_for(nurse) = @open[nurse].dup

  def waiting = @queues.values.flatten

  def complete(task)
    nurse = @owner.delete(task) or return false
    @open[nurse].delete(task)
    drain_queue
    true
  end

  def off_shift(nurse)
    index = @nurses.index(nurse)
    @nurses.delete_at(index)
    @next -= 1 if index < @next
    @next = 0 if @next >= @nurses.size
    @open.delete(nurse).to_a.each { |task| @owner.delete(task) && assign(task) }
  end

  private

  def next_with_room
    @nurses.size.times do |offset|
      index = (@next + offset) % @nurses.size
      nurse = @nurses[index]
      next if @open[nurse].size >= @capacity[nurse]

      @next = (index + 1) % @nurses.size
      return nurse
    end
    nil
  end

  def enqueue(task, priority)
    @queues.fetch(priority) << task
    nil
  end

  def drain_queue
    while (task = waiting.first) && (nurse = next_with_room)
      @queues.each_value { |queue| queue.delete(task) }
      @open[nurse] << task
      @owner[task] = nurse
    end
  end
end
