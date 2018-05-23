#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

running = true
Signal.trap(:TERM) { running = false }

def load_transactions(coin)
  # Download more transactions which is safer in case daemon haven't been active long time.
  # NOTE: The second argument of CoinRPC#listtransactions has different meaning for XRP. Check the sources.

  txs = []
  case coin.code
    when 'eth'
      txs = [] # not defined
    else
      txs = CoinRPC[coin.code].listtransactions('payment', 100)
  end
  txs
rescue => e
  Rails.logger.fatal e.inspect
  [] # Fallback with empty transaction list.
end

def process_transaction(coin, channel, tx)

  return if tx['category'] != 'receive'

  # Skip if transaction exists.
  return if PaymentTransaction::Normal.where(txid: tx['txid']).exists?

  # Skip zombie transactions (for which addresses don't exist).
  return unless PaymentAddress.where(address: tx['address']).exists?

  Rails.logger.info "Missed #{coin.code.upcase} transaction: #{tx['txid']}."

  # Immediately enqueue job.
  AMQPQueue.enqueue :deposit_coin, { txid: tx['txid'], channel_key: channel.key }
rescue => e
  Rails.logger.fatal e.inspect
end

while running
  channels = DepositChannel.all.each_with_object({}) { |ch, memo| memo[ch.currency] = ch }
  coins    = Currency.where(coin: true)

  coins.each do |coin|
    next unless (channel = channels[coin.code])

    load_transactions(coin).each do |tx|
      break unless running
      process_transaction(coin, channel, tx)
    end
  end

  Kernel.sleep 5
end
