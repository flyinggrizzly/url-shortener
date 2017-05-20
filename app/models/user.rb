class User < ApplicationRecord
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
  validates :password, presence: true, length: { minimum: 16 }

  # Class methods
  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ?BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  end

  private

  ### Filters ###

  def downcase_email
    email.downcase!
  end
end
