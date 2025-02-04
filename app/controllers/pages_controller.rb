class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :sign_up]
  skip_after_action :verify_policy_scoped, only: [:home, :sign_up]  # Add this line

  def home
    authorize :page, :home?
  end

  def sign_up
    authorize :page, :sign_up?
  end
end
