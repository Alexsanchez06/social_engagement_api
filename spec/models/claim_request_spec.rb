require 'rails_helper'

RSpec.describe ClaimRequest, type: :model do
  describe '#settle' do
    let(:claim_request) { create(:claim_request) }
    let(:reward) { create(:reward, quantity: 10) }
    let(:amount) { 5 }
    let(:txn_hash) { 'some_transaction_hash' }

    it 'updates the ClaimRequest attributes and decreases the reward quantity' do
      claim_request.reward = reward
      claim_request.quantity = 3
      claim_request.save

      expect {
        claim_request.settle(amount, txn_hash)
      }.to change { claim_request.reload.status }.from(nil).to(ClaimRequest::STATUS.CLAIMED)
       .and change { claim_request.reload.allocated_tokens }.from(nil).to(amount)
       .and change { claim_request.reload.claimed_at }.from(nil).to(Time.now.utc)
       .and change { claim_request.reload.message }.from(nil).to(txn_hash)
       .and change { reward.reload.quantity }.from(10).to(7)
    end
  end
end

