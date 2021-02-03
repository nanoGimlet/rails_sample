class Micropost < ApplicationRecord
  belongs_to :user, required: true, class_name: "User"
  has_many :microposts, dependent: :destroy, class_name: "Micropost"
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size

  scope :including_replies, -> (user) { 
    where(user_id: user.following_ids).or(where(user_id: user.id)).or(where(in_reply_to: user.id))
  }

  private

    # アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
