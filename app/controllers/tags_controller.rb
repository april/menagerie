class TagsController < ApplicationController

  def dispute
    @illustration_tag = IllustrationTag.find(params[:id])

    captcha = Typhoeus.post("https://www.google.com/recaptcha/api/siteverify", body: {
      secret: ENV.fetch("GOOGLE_CAPTCHA_SECRET"),
      response: params["g-recaptcha-response"],
      remoteip: request.remote_ip
    })

    unless JSON.parse(captcha.response_body)["success"]
      return render json: { success: false, error: "Invalid captcha" }, status: 400
    end

    @illustration_tag.update_attributes(disputed: true)
    return render json: { success: true }, status: 200
  end

end