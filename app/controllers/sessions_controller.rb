# Username-only sign-in and sign-out.
class SessionsController < ApplicationController
  allow_anonymous only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.sign_in(params.expect(session: [ :name ])[:name])
    return render(:new, status: :unprocessable_content) unless @user.persisted?

    start_session_for(@user)
    redirect_to root_path, notice: t(".signed_in", name: @user.name)
  end

  def destroy
    reset_session
    redirect_to new_session_path, notice: t(".signed_out")
  end

  private

  def start_session_for(user)
    reset_session
    session[:user_id] = user.id
  end
end
