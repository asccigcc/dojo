# Base class for Dojo's view components.
class ApplicationComponent < ViewComponent::Base
  include Turbo::FramesHelper
  private

  def markdown(text) = MarkdownRenderer.render(text)
end
