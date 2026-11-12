# Signs a user in through the real sessions endpoint so request specs exercise
# the same cookie path as the browser.
module SignInHelper
  def sign_in(user)
    post session_path, params: { session: { name: user.name } }
  end
end

RSpec.configure { |config| config.include SignInHelper, type: :request }
