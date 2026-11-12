# Base controller: every page requires a signed-in user unless a controller
# opts out with `allow_anonymous`.
class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :require_sign_in
  helper_method :current_user

  # Skips the sign-in requirement for the given actions.
  #
  # @param options [Hash] the usual `skip_before_action` filters (`only:`, `except:`)
  # @return [void]
  def self.allow_anonymous(**options)
    skip_before_action :require_sign_in, **options
  end

  private

  def current_user
    Current.user ||= User.find_by(id: session[:user_id])
  end

  def require_sign_in
    redirect_to new_session_path unless current_user
  end
end
