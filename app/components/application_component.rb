# Base class for Dojo's view components.
class ApplicationComponent < ViewComponent::Base
  include Turbo::FramesHelper
  private

  def markdown(text) = MarkdownRenderer.render(text)

  # @param version [Integer, nil] nil leaves the fragment unversioned (always applied)
  def stream_version_attribute(version)
    version ? tag.attributes(data: { stream_version: version }) : ""
  end
end
