# A colored pill for a submission or progress status.
class StatusBadgeComponent < ApplicationComponent
  COLORS = {
    "passed" => "bg-emerald-100 text-emerald-800", "failed" => "bg-rose-100 text-rose-800",
    "error" => "bg-amber-100 text-amber-800", "timeout" => "bg-amber-100 text-amber-800",
    "running" => "bg-sky-100 text-sky-800", "pending" => "bg-slate-100 text-slate-700"
  }.freeze

  # @param status [String]
  def initialize(status:)
    @status = status.to_s
  end

  def call
    tag.span(t("statuses.#{@status}", default: @status.humanize),
      class: "inline-block rounded-full px-2 py-0.5 text-xs font-medium #{COLORS.fetch(@status, COLORS['pending'])}")
  end
end
