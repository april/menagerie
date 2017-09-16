class Administrator < ActiveRecord::Base

  # -----------------------------------------------------------------------------
  # AUTHENTICATION SYSTEM
  # The admin must request a grant token challenge via email.
  # To pass the challenge, the admin must return to the site with the token.
  # -----------------------------------------------------------------------------

  BCRYPT_COST = 14
  GRANT_LIFESPAN = 15.minutes
  LOCKOUT_THRESHOLD = 16
  LOCKOUT_DURATION = 1.5.hours

  def self.generate_security_token
    SecureRandom.base64(32).delete("+/=")[0..31]
  end

  def generate_grant!
    plaintext_grant = self.class.generate_security_token
    encrypted_grant = BCrypt::Password.create(plaintext_grant, cost:BCRYPT_COST)
    self.update(grant_token:encrypted_grant, grant_token_expires_at:GRANT_LIFESPAN.from_now)
    return plaintext_grant
  end

  def send_grant_email!(context:)
    plaintext_grant = self.generate_grant!
    if Admin::SessionMailer.grant(administrator:self, plaintext_grant:plaintext_grant, context:context).deliver_now
      self.accrue_strike!
      return true
    else
      return false
    end
  end

  def authenticate!(password)
    # WARNING: Always run bcrypt first so that we incur the time penalty
    bcrypt_valid = BCrypt::Password.new(self.grant_token) == password
    # Reject if currently locked
    return false if self.locked?
    # WARNING: Always perform the secure comparison ahead of other checks
    if bcrypt_valid && grant_window?
      self.consume_grant!
      return true
    else
      self.accrue_strike!
      return false
    end
  end

  # Add one strike to the account.
  # An admin is given a strike for requesting a grant or flunking a challenge.
  # Will lock the account if they’ve hit the threshold.
  def accrue_strike!
    self.update(lockout_strikes: self.lockout_strikes + 1)
    self.lock_account! if self.lockout_strikes >= LOCKOUT_THRESHOLD
  end

  # Lock this account immediately and reset lockout strikes.
  def lock_account!
    self.update(unlocks_at:LOCKOUT_DURATION.from_now, lockout_strikes:0)
  end

  # Invalidate the current grant and reset lockout strikes.
  # Shoud be called when the admin sucessfully authenticates
  def consume_grant!
    self.update(grant_token_expires_at:Time.current, lockout_strikes:0)
  end

  # True if this admin is allowed to attempt grant challenges,
  # and their current grant token has not expired.
  def grant_window?
    return Time.current < self.grant_token_expires_at
  end

  # True if this account is locked out
  def locked?
    return Time.current < self.unlocks_at
  end

  def unlock_account!
    self.update(unlocks_at:Time.current, lockout_strikes:0)
  end

  def rotate_auth_key!
    self.update(auth_key:self.class.generate_security_token)
  end

  def self.panic!
    self.all.each do |admin|
      admin.rotate_auth_key!
      admin.generate_grant!
      admin.consume_grant!
    end
  end

end
