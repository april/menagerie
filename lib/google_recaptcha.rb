module GoogleRecaptcha

  def self.verify?(response_code, remote_ip)
    captcha = Typhoeus.post("https://www.google.com/recaptcha/api/siteverify", body: {
      secret: ENV.fetch("GOOGLE_CAPTCHA_SECRET"),
      response: response_code,
      remoteip: remote_ip
    })

    return JSON.parse(captcha.response_body)["success"]
  end

end