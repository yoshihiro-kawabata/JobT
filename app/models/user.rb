class User < ApplicationRecord
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
end
