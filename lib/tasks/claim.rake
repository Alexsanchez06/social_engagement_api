namespace :claim do

  EPOCH_ID = 18
  NETWORK = :skale
  LIMIT = 10
  VERIFY_MESSAGE = "Sign to confirm:
    - Your ownership of the Twitter account @%{username}
    - Your credit claim
    - Acceptance of the Terms and Conditions"

  def verify(claim, network)
    verify_sign(claim, network)
    verify_quantity(claim, network)
    true
  end

  def verify_sign(claim, network)
    username, sign, address = claim.user.username, claim.sign, claim.address
    status = Eth::Signature.verify(VERIFY_MESSAGE % {username:}, sign, address, network.client.chain_id) 
    raise("Sign verification failed") unless status
    true
  end

  def verify_quantity(claim, network)
    return true if claim.quantity == ClaimRequest::FULL_CLAIM_NAME

    credits_ratio = network.config.credits_ratio.to_f
    raise("Quantity can't be less than 0") if claim.quantity.to_f <= 0
    true
  end

  def verify_txn(network, txn_hash)
    status = false
    5.times do
      status = network.client.tx_succeeded?(txn_hash)
      puts "--- status #{status}"
      return true if status
      sleep 1
    end

    status
  end

  # rails claim:process validate
  # rails claim:process allocate
  # rails claim:process distribute
  task :process => :environment do
    process_type = ARGV.first.intern

    raise "\nError: Unknow type #{process_type}" unless [:allocate, :validate, :distribute].include? process_type

    is_validation = process_type == :validate
    is_allocation = process_type == :allocate
    is_distribution = process_type == :distribute

    epoch = Epoch.unscoped.find(EPOCH_ID)

    if epoch.alive || Time.now.utc <= epoch.end_time
      # raise "Invalid epoch #{epoch.attributes}"
    end

    network = Network::Ethereum.new(:skale)
    client = network.client
    credits_ratio = network.config.credits_ratio.to_f        

    while(true)

      if is_validation
        requests = epoch.claim_requests.for_validation.asc
      elsif is_allocation
        requests = epoch.claim_requests.for_allocation.asc
      elsif is_distribution
        requests = epoch.claim_requests.for_claim.asc
      else
        raise "\nError: Unknow type #{process_type}"
      end

      puts "\n-- Batch processing... Pending - #{requests.count} --\n"
      raise "\nNo request to process\n" if requests.count < 1

      requests.limit(LIMIT).each.with_index do |claim, i|
        begin
          if is_validation
            verify(claim, network)   
            claim.update!(status: ClaimRequest::STATUS.VERIFIED, updated_at: Time.now.utc)
            next
          end
          if is_allocation
            quantity = claim.claimable_quantity * credits_ratio
            claim.update!(quantity: claim.claimable_quantity, allocated_tokens: quantity, status: ClaimRequest::STATUS.ALLOCATED, updated_at: Time.now.utc, claimed_at: Time.now.utc)
            next
          end

          if is_distribution && claim.status == ClaimRequest::STATUS.ALLOCATED
            network.client.max_fee_per_gas = (0.0001 * Eth::Unit::GWEI).freeze
            amount = claim.allocated_tokens
            # address = "0x54f3fA4D04872A5468111f9a8F7445b4d165297f" || claim.address
            address = Eth::Address.new(claim.address).address
            txn_hash = network.transfer_erc20(to: address, amount: amount)
            raise("Transaction failed") unless verify_txn(network, txn_hash)
            claim.settle(amount, txn_hash)
          end
        rescue => err
          puts "#{err.class} #{err}"
          claim.update!(status: ClaimRequest::STATUS.FAILED, message: err.message)
        end
      end
    end

    puts "--- Claim Completed ---"
  end
end
