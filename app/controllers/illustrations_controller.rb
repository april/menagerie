class IllustrationsController < ApplicationController

  def random
    @illustration = Illustration.includes(:tags).where(tagged: nil).order("RANDOM()").first
    @illustration = Illustration.includes(:tags).order("RANDOM()").first unless @illustration
    return redirect_to show_illustration_path(@illustration.slug)
  end

  def show
    @illustration = Illustration.includes(:illustration_tags, :tags).where(slug: params[:slug]).first
    raise ActiveRecord::RecordNotFound unless @illustration.present?
  end

  def submit_tags
    @illustration = Illustration.find(params[:id])
    @tags = @illustration.new_tags(params.fetch(:tags, []))

    captcha = Typhoeus.post("https://www.google.com/recaptcha/api/siteverify", body: {
      secret: ENV.fetch("GOOGLE_CAPTCHA_SECRET"),
      response: params["g-recaptcha-response"],
      remoteip: request.remote_ip
    })

    unless JSON.parse(captcha.response_body)["success"]
      return render json: { success: false, error: "Invalid captcha" }, status: 400
    end

    unless @tags.any?
      return render json: { success: false, error: "No new tags were submitted" }, status: 400
    end

    return render json: {
      success: true,
      form: render_to_string(template: "illustrations/_confirm", layout: false).squish.html_safe
    }, status: 200
  end

  def create_tags
    @illustration = Illustration.find(params[:id])
    @illustration.create_tags!(params.fetch(:tags, {}).values)
    flash[:notice] = "Your tags have been created"
    return redirect_to show_illustration_path(@illustration.slug)
  end

end