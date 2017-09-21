# frozen_string_literal: true

class TagsController < ApplicationController

  def submit
    @illustration = Illustration.find(params[:id])

    if error_message = verify_submission!
      return render json: { success: false, error: error_message }, status: 400
    end

    @tag_submission = TagSubmission.new(illustration: @illustration, source_ip: request.remote_ip, created_at: Time.now)
    @tag_submission.propose_tags(submit_params[:tags])

    return render json: { success: false, error: "No new tags were submitted" }, status: 400 unless @tag_submission.proposed_tags.reject(&:duplicate?).any?

    @tag_submission.save

    return render json: {
      success: true,
      form: render_to_string(template: "illustrations/_confirm", layout: false).squish.html_safe
    }, status: 200
  end

  def create
    @tag_submission = TagSubmission.includes(:illustration).find(params[:id])
    @tag_submission.create_illustration_tags!(create_params)
    flash[:notice] = "Your tags have been created"
    return redirect_to show_illustration_path(@tag_submission.illustration.slug)
  end

  def dispute
    @illustration_tag = IllustrationTag.includes(:illustration).find(params[:id])

    if valid_captcha?
      @illustration_tag.update_attributes({
        dispute_note: dispute_params[:dispute_note].presence,
        disputed: true,
      })
      flash[:notice] = "Your tag dispute has been reported"
    else
      flash[:notice] = "Invalid captcha for tag dispute"
    end

    return redirect_to show_illustration_path(@illustration_tag.illustration.slug)
  end

private

  def submit_params
    params.require(:tag_submission).permit(:accept_guidelines, :accept_tos, :tags => [])
  end

  def create_params
    # we have a variable-sized hash of returned keys, so we have to manually whitelist.
    # the TagSubmission has a record of valid values, all others will be ignored.
    params.fetch(:tag_confirmation, {}).fetch(:tags, {}).values
  end

  def dispute_params
    params.require(:tag_dispute).permit(:dispute_note)
  end

  def verify_submission!
    return "You must agree to follow submissions guidelines" unless submit_params[:accept_guidelines] == "1"
    return "You must agree to the terms of service" unless submit_params[:accept_tos] == "1"
    return "Invalid captcha" unless valid_captcha?
  end

  def valid_captcha?
    return true

    captcha = Typhoeus.post("https://www.google.com/recaptcha/api/siteverify", body: {
      secret: ENV.fetch("GOOGLE_CAPTCHA_SECRET"),
      response: params["g-recaptcha-response"],
      remoteip: request.remote_ip
    })

    return JSON.parse(captcha.response_body)["success"]
  end

end