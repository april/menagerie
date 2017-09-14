class IllustrationsController < ApplicationController

  def random
    @illustration = Illustration.includes(:tags).where(tagged: nil).order("RANDOM()").limit(1).first
    @illustration = Illustration.includes(:tags).order("RANDOM()").limit(1).first unless @illustration
    return redirect_to show_illustration_path(@illustration)
  end

  def show
    @illustration = Illustration.includes(:illustration_tags, :tags).find(params[:id])
  end

  def submit_tags
    @illustration = Illustration.find(params[:id])
    @tags = @illustration.new_tags(params.fetch(:tags, {}).values)

    captcha = Typhoeus.post("https://www.google.com/recaptcha/api/siteverify", body: {
      secret: "6LdLnjAUAAAAADpYUQxI5_2_0CSvNsFiZSP6AMq8",
      response: params["g-recaptcha-response"],
      remoteip: request.remote_ip
    })

    unless JSON.parse(captcha.response_body)["success"]
      flash[:notice] = "Invalid captcha"
      return redirect_to show_illustration_path(@illustration)
    end

    unless @tags.any?
      flash[:notice] = "No new tags were submitted"
      return redirect_to show_illustration_path(@illustration)
    end

    render :confirm
  end

  def create_tags
    @illustration = Illustration.find(params[:id])
    @illustration.create_tags!(params.fetch(:tags, {}).values)
    flash[:notice] = "Your tags have been created"
    return redirect_to show_illustration_path(@illustration)
  end

end