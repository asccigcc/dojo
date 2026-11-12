require "rails_helper"

RSpec.describe "Sessions" do
  it "redirects anonymous visitors to the sign-in page" do
    get root_path

    expect(response).to redirect_to(new_session_path)
  end

  it "signs in with just a username and lands on Today" do
    post session_path, params: { session: { name: "Ana" } }

    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Ana")
  end

  it "re-renders the form for an invalid name" do
    post session_path, params: { session: { name: "" } }

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "signs out" do
    post session_path, params: { session: { name: "Ana" } }
    delete session_path

    expect(response).to redirect_to(new_session_path)
    get root_path
    expect(response).to redirect_to(new_session_path)
  end
end
