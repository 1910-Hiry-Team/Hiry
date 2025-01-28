class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :sign_up]

  def home
  end

  def sign_up
  end
end
