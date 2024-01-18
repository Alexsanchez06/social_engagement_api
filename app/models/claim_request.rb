class ClaimRequest < ApplicationRecord
  STATUS = OpenStruct.new(REQUESTED: 'REQUESTED', VERIFIED: 'VALIDATED', ALLOCATED: 'ALLOCATED', CLAIMED: 'CLAIMED', FAILED: 'FAILED')
  PUBLIC_FIELDS = [:id, :epoch_id, :user_id, :reward_id, :quantity, :allocated_tokens, :address, :status, :message, :claimed_at, :created_at, :updated_at]
  FULL_CLAIM_NAME = 'ALL'

  belongs_to :epoch
  belongs_to :user
  belongs_to :reward

  validates :quantity, :address, :sign, :user, :epoch, presence: true
  validates :reward, presence: { message: "Your contribution is not found" }
  validate :validate_rewards

  scope :pending, ->{ where("status != ? and status != ?", STATUS.CLAIMED, STATUS.FAILED) }

  scope :for_validation, ->{ where("status = ?", STATUS.REQUESTED) }
  scope :for_allocation, ->{ where("status = ?", STATUS.VERIFIED) }
  scope :for_claim, ->{ where("status = ?", STATUS.ALLOCATED) }

  scope :desc, ->{ order("ID DESC") }
  scope :asc, ->{ order("ID ASC") }

  def full_claim?
    quantity == ClaimRequest::FULL_CLAIM_NAME
  end

  def claimable_quantity
    (full_claim? ? self.reward.total_activity_points : self.quantity).to_f
  end

  def validate_rewards
    if quantity != FULL_CLAIM_NAME && quantity.to_i < 1
      errors.add(:base, "Invalid Quantity") 
      return
    end

    if reward
      return true if quantity == ClaimRequest::FULL_CLAIM_NAME

      # if quantity.to_i > reward.total_activity_points.to_i
      #   errors.add(:base, "Quantity can't be more than earned")
      # end
    else
      errors.add(:base, "Your contribution is not found")
    end

    # -- Required only for partial claims
    # if (requested_quantity + quantity.to_i) > reward.total_activity_points.to_i
    #   errors.add(:base, "Quantity can't be more than already requested quantity")
    # end
  end

  def requested_quantity
    ClaimRequest.where(epoch: self.epoch, user: self.user, reward: self.reward).pluck(:quantity).sum(&:to_i)
  end

  def settle(amount, txnHash)    
    self.update_columns(status: ClaimRequest::STATUS.CLAIMED, allocated_tokens: amount, claimed_at: Time.now.utc, message: txnHash)
    # TODO: Required only for 
    # self.reward.update_columns(quantity: self.reward.total_activity_points.to_i - self.quantity.to_f)
  end
end
