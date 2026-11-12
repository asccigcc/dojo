# Undo-log design: each transaction remembers only the first previous value
# of every key it touches, so begin_tx is O(1) and rollback is O(changes).
class Store
  MISSING = Object.new.freeze

  def initialize
    @data = {}
    @counts = Hash.new(0)
    @undo_stack = []
  end

  def get(key) = @data[key]

  def set(key, value)
    remember(key)
    write(key, value)
  end

  def delete(key)
    return false unless @data.key?(key)

    remember(key)
    write(key, MISSING)
    true
  end

  def count(value) = @counts[value]

  def begin_tx = @undo_stack.push({})

  def rollback
    log = @undo_stack.pop or return false
    log.each { |key, previous| write(key, previous) }
    true
  end

  def commit
    return false if @undo_stack.empty?

    @undo_stack.clear
    true
  end

  def keys_with_prefix(prefix) = @data.keys.select { |k| k.start_with?(prefix) }.sort

  private

  def remember(key)
    log = @undo_stack.last or return
    log[key] = @data.fetch(key, MISSING) unless log.key?(key)
  end

  def write(key, value)
    @counts[@data[key]] -= 1 if @data.key?(key)
    if value.equal?(MISSING)
      @data.delete(key)
    else
      @data[key] = value
      @counts[value] += 1
    end
  end
end
