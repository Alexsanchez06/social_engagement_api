require 'eth'

# skale = Network::Ethereum.new(:skale)
# skale.transfer(to: '0x54f3fA4D04872A5468111f9a8F7445b4d165297f', amount: 0.000000001)

# skale = Network::Ethereum.new(:skale)
# skale.transfer_erc20(to: '0x54f3fA4D04872A5468111f9a8F7445b4d165297f', amount: 1)

module Network
  class Ethereum
    attr_accessor :network, :client, :config, :erc20

    ERC20_ABI = JSON.parse(File.read("lib/network/abi/erc20.abi"))
    CONTRACT_ADDRESS = Eth::Address.new("0xd8220e4525A8a433586BE429742dDe60fa57259a").address
    ERC20_CONTRACT = Eth::Contract.from_abi(abi: ERC20_ABI, name: "SKL", address: CONTRACT_ADDRESS)

    GAS_PRICE = {
      skale: -> (){ (0.0001 * Eth::Unit::GWEI).freeze }
    }
    
    def initialize(network)
      self.network = network
      self.config = AppConfig.network(network)
      self.client = Eth::Client.create(config.rpc)
      self.client.max_fee_per_gas = GAS_PRICE[self.network].call if GAS_PRICE[self.network].present?
    end

    def transfer(to:, amount:, options: {})
      amount_in_wei = amount.to_f * 10**(config.decimals.to_i || 18) # 1 Ether
      options[:nonce] ||= client.get_nonce(config.public_address)      
      sender_key = Eth::Key.new(priv: config.private_key)
      client.transfer_and_wait(to, amount_in_wei, legacy: true, sender_key: sender_key, nonce: options[:nonce])
    end

    def transfer_erc20(to:, amount:, options: {})
      amount_in_wei = amount.to_f * 10**(config.decimals.to_i || 18) # 1 Ether
      options[:nonce] ||= client.get_nonce(config.public_address)
      sender_key = Eth::Key.new(priv: config.private_key)
      client.transfer_erc20_and_wait(ERC20_CONTRACT, to, amount_in_wei, gas_limit: 90000, legacy: true, sender_key: sender_key, nonce: options[:nonce])
    end
  end
end