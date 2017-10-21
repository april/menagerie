# frozen_string_literal: true

class TagsController < ApplicationController

  def submit_illustration_tags
    return submit(Illustration.includes(:tags).find(params[:id]))
  end

  def submit_oracle_card_tags
    return submit(OracleCard.includes(:tags).find(params[:id]))
  end

  def create
    @tag_submission = TagSubmission.includes(:taggable).find(params[:id])
    @tag_submission.create_content_tags!(create_params)
    flash[:notice] = "Your tags have been created"
    return redirect_to_taggable(@tag_submission.taggable, params[:via])
  end

  def dispute
    @content_tag = ContentTag.includes(:taggable).find(params[:id])

    if valid_captcha?
      @content_tag.update_attributes({
        dispute_note: dispute_params[:dispute_note].presence,
        disputed: true,
      })
      flash[:notice] = "Your tag dispute has been reported"
    else
      flash[:notice] = "Invalid captcha for tag dispute"
    end

    return redirect_to_taggable(@content_tag.taggable, params[:via])
  end

private

  def submit(taggable)
    @taggable = taggable

    if error_message = validate_submission!
      return render json: { success: false, error: error_message }, status: 400
    end

    @tag_submission = TagSubmission.new(taggable: @taggable, source_ip: request.remote_ip, created_at: Time.now)
    @tag_submission.propose_tags(submit_params[:tags])

    return render json: { success: false, error: "No new tags were submitted" }, status: 400 unless @tag_submission.proposed_tags.reject(&:duplicate?).any?

    @tag_submission.save

    return render json: {
      success: true,
      form: render_to_string(template: "taggables/_confirm", layout: false).squish.html_safe
    }, status: 200
  end

  def submit_params
    params.require(:tag_submission).permit(:accept_terms, :tags => [])
  end

  def create_params
    # we have a variable-sized hash of returned keys, so we have to manually whitelist.
    # the TagSubmission has a record of valid values, all others will be ignored.
    params.fetch(:tag_confirmation, {}).fetch(:tags, {}).values
  end

  def dispute_params
    params.require(:tag_dispute).permit(:dispute_note)
  end

  def validate_submission!
    return "You must agree to the submission terms" unless submit_params[:accept_terms] == "1"
    return "Invalid captcha" unless valid_captcha?
  end

  def valid_captcha?
    return true if Rails.env.development?

    captcha = Typhoeus.post("https://www.google.com/recaptcha/api/siteverify", body: {
      secret: ENV.fetch("GOOGLE_CAPTCHA_SECRET"),
      response: params["g-recaptcha-response"],
      remoteip: request.remote_ip
    })

    return JSON.parse(captcha.response_body)["success"]
  end

  # Redirects to a taggable presentation page, or homepage.
  # OracleCards allow a passed "via" param that directs back to the referring illustration.
  def redirect_to_taggable(taggable, via_slug)
    if taggable.is_a?(Illustration)
      return redirect_to show_illustration_path(taggable.slug)
    elsif taggable.is_a?(OracleCard) && via_slug.present?
      return redirect_to show_oracle_card_path(via_slug)
    else
      return redirect_to home_path
    end
  end

end