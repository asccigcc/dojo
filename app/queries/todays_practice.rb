# Today's practice: one warm-up and one problem. For each kind it prefers
# what you started today and have not passed yet, then the most overdue
# review, then the next item you have never tried.
class TodaysPractice
  Pick = Data.define(:exercise, :reason)

  # @param user [User]
  # @param now [Time]
  def initialize(user, now: Time.current)
    @user = user
    @now = now
  end

  # @return [Pick, nil]
  def warmup = @warmup ||= pick("warmup")

  # @return [Pick, nil]
  def problem = @problem ||= pick("problem")

  # @return [Array<Progress>] exercises fully passed today, exercise preloaded
  def done_today
    progresses.where(last_attempted_at: start_of_day.., last_result: "passed").where("progresses.next_review_at > ?", @now)
      .order(last_attempted_at: :desc).to_a
  end

  private

  def pick(kind)
    found = in_progress(kind) and return Pick.new(found, :in_progress)
    found = most_overdue(kind) and return Pick.new(found, :due)
    found = next_unseen(kind) and Pick.new(found, :new)
  end

  def in_progress(kind)
    of_kind(kind).where(last_attempted_at: start_of_day..)
      .where("progresses.last_result != 'passed' OR progresses.next_review_at <= ?", @now)
      .order(last_attempted_at: :desc).first&.exercise
  end

  def most_overdue(kind) = of_kind(kind).due(@now).order(:next_review_at).first&.exercise

  def next_unseen(kind)
    unseen = Exercise.where(kind:).where.not(id: @user.progresses.select(:exercise_id)).in_catalog_order
    kind == "warmup" ? rotate(unseen.to_a) : unseen.first
  end

  def rotate(unseen)
    order = Exercise.warmup.in_catalog_order.pluck(:category).uniq
    last = of_kind("warmup").where.not(last_attempted_at: nil).order(last_attempted_at: :desc).first
    WarmupRotation.new(unseen, order:, after: last&.exercise&.category).next
  end

  def of_kind(kind) = progresses.where(exercises: { kind: })

  def progresses = @user.progresses.joins(:exercise).includes(:exercise)

  def start_of_day = @now.beginning_of_day
end
