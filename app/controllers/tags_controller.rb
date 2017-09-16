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

  def confirm
    @illustration_tag = IllustrationTag.find(params[:id])
    @illustration_tag.verified = (params[:approved] == "true")
    @illustration_tag.disputed = false

    begin
      if @illustration_tag.verified
        if params[:approved_name] != @illustration_tag.name
          old_tag = @illustration_tag.tag
          @illustration_tag.tag = Tag.find_or_create_by(name: params[:approved_name])
          old_tag.destroy if old_tag.illustration_tags.count < 1
        end
        @illustration_tag.save
      else
        @illustration_tag.destroy
      end
      return render json: { success: true }, status: 200
    rescue
      return render json: { success: false }, status: 400
    end
  end

end