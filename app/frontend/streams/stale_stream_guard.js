/**
 * Drops Turbo Stream `replace` actions that would put an older state on the
 * page than the one already shown.
 *
 * Action Cable can deliver broadcasts out of order (worker pools), and the
 * Run request's own response can land after the job's final broadcast. Each
 * live fragment carries `data-stream-version` (see Submission#stream_version).
 * A replacement with a lower version than the current element is skipped.
 * Unversioned fragments always apply.
 *
 * The check runs at render time, not at event time, because Turbo awaits a
 * repaint between `turbo:before-stream-render` and rendering, and two streams
 * can be in flight at once.
 */

/**
 * @param {Element | null} current element now on the page
 * @param {Element | null} incoming first element of the stream's template
 * @returns {boolean} true when incoming is older than current
 */
export function isStale(current, incoming) {
  const now = Number(current?.dataset?.streamVersion)
  const next = Number(incoming?.dataset?.streamVersion)
  if (Number.isNaN(now) || Number.isNaN(next)) return false
  return next < now
}

/**
 * Wraps each replace stream's renderer with the staleness check.
 * @param {Document} doc
 */
export function installStaleStreamGuard(doc = document) {
  doc.addEventListener("turbo:before-stream-render", (event) => {
    const stream = event.target
    if (stream.action !== "replace") return

    const render = event.detail.render
    event.detail.render = (element) => {
      const incoming = element.templateContent.firstElementChild
      if (!isStale(doc.getElementById(element.target), incoming)) return render(element)
    }
  })
}
