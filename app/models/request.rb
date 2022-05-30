class Request < ApplicationRecord
  validates :period, presence: true
  validates :reason, presence: true
  belongs_to :user
  has_and_belongs_to_many :documents

  validate :start_end_check

  def start_end_check
    errors.add(:end_time, "は開始時間より前には登録できません。") unless
    self.start_time <= self.end_time
  end


end
