# The home page: today's practice.
class HomeController < ApplicationController
  def show
    @today = TodaysPractice.new(current_user)
  end
end
