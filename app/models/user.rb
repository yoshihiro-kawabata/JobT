class User < ApplicationRecord
    attr_accessor :remember_token
    validates :number, presence: true, length: { maximum: 30 }
    validates :name, presence: true, length: { maximum: 30 }
    validates :email, presence: true, length: { maximum: 255 }, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
    before_validation { email.downcase! }
    has_secure_password
    validates :password, length: { minimum: 6 }
    has_and_belongs_to_many :groups
    has_and_belongs_to_many :templetes
    has_many :attendances
    has_many :consents
    has_many :messages
    has_many :reports
    has_many :requests
    has_many :schedules

    def self.new_token
        SecureRandom.urlsafe_base64
      end

    def self.digest(string) 
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
    
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end

    def forget
        update_attribute(:remember_digest, nil)
    end

end
