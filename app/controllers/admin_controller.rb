# frozen_string_literal: true

class AdminController < ApplicationController

  before_action :authenticate_administrator!
  helper_method :logged_in?

  def authenticate_administrator!
    unless current_administrator
      flash[:error] = "You must sign in to continue. Enter your administrator email below."
      return redirect_to(admin_new_session_path, status:303)
    end
  end

  def current_administrator
    @current_administrator ||= Administrator.find_by(auth_token:cookies.encrypted[:admin_auth_token])
  end

  def logged_in?
    current_administrator.present?
  end

end