import { Controller } from "@hotwired/stimulus"
import { EditorView, basicSetup } from "codemirror"
import { keymap } from "@codemirror/view"
import { Prec } from "@codemirror/state"
import { indentWithTab } from "@codemirror/commands"
import { StreamLanguage, indentUnit } from "@codemirror/language"
import { ruby } from "@codemirror/legacy-modes/mode/ruby"

/**
 * Mounts a CodeMirror 6 Ruby editor over the submission form's textarea.
 *
 * The textarea stays the form field (and the no-JS fallback); every edit is
 * copied into it, so a normal Turbo form submit sends the editor's code.
 *
 * Targets:
 *   - mount: element CodeMirror renders into
 *   - input: the `submission[code]` textarea (hidden once the editor mounts)
 * Values:
 *   - starter: starter code restored by the Reset button
 * Keys: Tab indents, Shift+Tab dedents, Cmd/Ctrl+Enter runs.
 */
export default class extends Controller {
  static targets = ["mount", "input"]
  static values = { starter: String }

  /** Creates the editor with the textarea's current code. */
  connect() {
    this.view = new EditorView({
      doc: this.inputTarget.value,
      parent: this.mountTarget,
      extensions: this.extensions(),
    })
    this.inputTarget.hidden = true
  }

  /** Tears the editor down so Turbo cache snapshots stay clean. */
  disconnect() {
    this.view?.destroy()
    this.inputTarget.hidden = false
  }

  /** Replaces the editor content with the starter code. */
  reset() {
    const length = this.view.state.doc.length
    this.view.dispatch({ changes: { from: 0, to: length, insert: this.starterValue } })
    this.view.focus()
  }

  /**
   * Submits the form, as if Run were clicked.
   * @returns {boolean} true so CodeMirror stops handling the key
   */
  run() {
    this.element.requestSubmit()
    return true
  }

  /** @returns {import("@codemirror/state").Extension[]} */
  extensions() {
    return [
      basicSetup,
      StreamLanguage.define(ruby),
      indentUnit.of("  "),
      Prec.highest(keymap.of([{ key: "Mod-Enter", run: () => this.run() }])),
      keymap.of([indentWithTab]),
      EditorView.updateListener.of((update) => this.sync(update)),
      EditorView.theme({ "&": { minHeight: "18rem" }, ".cm-scroller": { fontFamily: "ui-monospace, monospace" } }),
    ]
  }

  /** @param {import("@codemirror/view").ViewUpdate} update */
  sync(update) {
    if (update.docChanged) this.inputTarget.value = update.state.doc.toString()
  }
}
