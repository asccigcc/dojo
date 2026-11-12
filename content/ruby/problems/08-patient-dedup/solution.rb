class Dedup
  NICKNAMES = { "bob" => "robert", "rob" => "robert", "bill" => "william",
                "will" => "william", "liz" => "elizabeth", "beth" => "elizabeth" }.freeze
  FIELDS = %i[first last dob phone].freeze

  def initialize
    @records = {}
  end

  def add(id, first:, last:, dob:, phone: nil)
    @records[id] = { first:, last:, dob:, phone: }
  end

  # Records sharing any match key are connected; groups are connected components.
  def duplicate_groups
    buckets = Hash.new { |h, key| h[key] = [] }
    @records.each { |id, record| match_keys(record).each { |key| buckets[key] << id } }
    components(buckets.values).select { |group| group.size > 1 }.map(&:sort).sort
  end

  def golden_record(ids)
    rows = ids.sort.map { |id| @records.fetch(id) }
    FIELDS.to_h { |field| [field, most_common(rows.map { |r| r[field] })] }
  end

  private

  def match_keys(record)
    keys = [[:name, first_name(record[:first]), letters(record[:last]), record[:dob]]]
    phone = record[:phone].to_s.gsub(/\D/, "")
    keys << [:phone, phone[-10..], record[:dob]] if phone.size >= 10
    keys
  end

  def letters(name) = name.to_s.downcase.gsub(/[^a-z]/, "")

  def first_name(name) = NICKNAMES.fetch(letters(name), letters(name))

  def components(buckets)
    neighbors = Hash.new { |h, id| h[id] = [] }
    buckets.each { |ids| ids.each { |id| neighbors[id].concat(ids) } }
    seen = {}
    @records.keys.filter_map do |id|
      next if seen[id]

      explore(id, neighbors, seen)
    end
  end

  def explore(start, neighbors, seen)
    stack = [start]
    group = []
    while (id = stack.pop)
      next if seen[id]

      seen[id] = true
      group << id
      stack.concat(neighbors[id])
    end
    group
  end

  # tally keeps first-seen order and max_by keeps the first max, so ties go to the lowest id.
  def most_common(values)
    values.reject { |v| v.nil? || v.to_s.strip.empty? }.tally.max_by { |_, count| count }&.first
  end
end
