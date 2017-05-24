class User < ApplicationRecord
  # Attributes
  attr_accessor :remember_token

  # Filters
  before_save :downcase_email

  # Name validations
  validates :name,  presence: true, length: { maximum: 50  }

  # Email validations
  VALID_EMAIL_REGEX = Regexp.new(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  validates :email, presence: true, length: { maximum: 255 }, 
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  # Password validations
  has_secure_password
  validates :password, presence: true, length: { minimum: 16 }, allow_nil: true

  has_many :short_urls

  ###### Class methods ################################################################################################

  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ?BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  ###### Instance methods #############################################################################################

  # Sets a remember token in the databse for persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_token, User.digest(remember_token))
  end

  # Forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given token matches the digest
  def authenticated?(token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(token)
  end

  ###### Private methods ##############################################################################################

  private

  ### Filters ###

  def downcase_email
    email.downcase!
  end
end
