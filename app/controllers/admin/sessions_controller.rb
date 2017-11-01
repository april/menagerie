class Admin::SessionsController < AdminController

  skip_before_action :authenticate_administrator!
  #layout "admin"

  def new
    return render :new
  end

  def request_grant
    unless @admin = Administrator.find_by(email:email_param)
      @error = "No administrator found with that email address."
      return render :message
    end
    if @admin.send_grant_email!(context:request)
      @message = "A magic sign-in link has been emailed to you. Find the message in your inbox to continue."
      return render :message
    else
      @message = "An email couldn’t be sent for you. Please contact a server administrator."
      return render :message
    end
  end

  def authenticate
    @admin = Administrator.find_by(email:email_param)
    if @admin && @admin.grant_window?
      @email = email_param
      @grant = grant_param
      return render :authenticate
    else
      @message = "The grant link you followed was invalid or has expired."
      return render :message
    end
  end

  def create
    @admin = Administrator.find_by(email:email_param)
    if @admin && @admin.authenticate!(grant_param)
      set_admin_cookies
      return redirect_to(admin_approve_tags, status:303)
    else
      @message = "The grant link you followed was invalid or has expired."
      return render :message
    end
  end

  def destroy
    destroy_admin_cookies
    reset_session
    return redirect_to(home_path, status:303)
  end

  protected

  def email_param
    @email_param ||= params[:email].to_s.downcase.squish
  end

  def grant_param
    @grant_param ||= params[:grant]
  end

  def set_admin_cookies
    cookies.encrypted[:admin_auth_token] = {
      value: @admin.auth_token,
      expires: 1.year.from_now,
      secure: Rails.env.production?, # Expect a TLS connection in production
      httponly: true, # JavaScript should not read this cookie
    }
    cookies.encrypted[:admin_mode] = {
      value: SecurityToken.generate, # Put nonsense in this cookie, but make it look like the admin token
      expires: 1.year.from_now,
      secure: Rails.env.production?, # Expect a TLS connection in production
      httponly: false, # JavaScript can detect this cookie
    }
  end

  def destroy_admin_cookies
    cookies.delete(:admin_auth_token)
    cookies.delete(:admin_mode)
  end

end
