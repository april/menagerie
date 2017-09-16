class Admin::SessionMailer < ActionMailer::Base

  default from:"Administration <noreply@illustrationtag.com>"

  def grant(administrator:, plaintext_grant:, context:)
    @email = administrator.email
    @plaintext_grant = plaintext_grant
    @context = context
    mail(to:administrator.email, subject:"Magic Link 🔮")
  end

end
