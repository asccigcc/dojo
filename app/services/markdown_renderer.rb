# Renders exercise Markdown. Raw HTML in the source is escaped: content is
# trusted (it is versioned in this repo) but there is no reason to allow it.
module MarkdownRenderer
  RENDERER = Redcarpet::Render::HTML.new(escape_html: true, hard_wrap: false)
  MARKDOWN = Redcarpet::Markdown.new(RENDERER, fenced_code_blocks: true, tables: true, autolink: false,
    no_intra_emphasis: true, strikethrough: true)

  # @param text [String, nil]
  # @return [ActiveSupport::SafeBuffer]
  def self.render(text) = MARKDOWN.render(text.to_s).html_safe # rubocop:disable Rails/OutputSafety -- input is HTML-escaped by Redcarpet
end
