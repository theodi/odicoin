require 'bitcoin/blockchain'
require 'bitcoin/node'
require 'bitcoin/blockchain/backends'

require 'eventmachine'

#chain = Bitcoin::Blockchain::Backends::Utxo.new(db: "sqlite://db/odicoin.db")

#puts chain

#storage = Bitcoin::Blockchain.create_store 'archive', db: 'sqlite:/'

#4.times do |i|
#  b = Bitcoin::Blockchain::Models::Block.from_file "#{i}.blk"
#  storage.store_block b
#end

Bitcoin::NETWORKS[:odicoin] = {
  project: :odicoin,
  magic_head: "DATA",
  address_version: "00",
  p2sh_version: "05",
  privkey_version: "80",
  extended_privkey_version: "0488ade4",
  extended_pubkey_version: "0488b21e",
  default_port: 6677,
  protocol_version: 70001,
  coinbase_maturity: 100,
  reward_base: 50 * Bitcoin::COIN,
  reward_halving: 210_000,
  retarget_interval: 2016,
  retarget_time: 1209600, # 2 weeks
  target_spacing: 60, # block interval
  max_money: 21_000_000 * Bitcoin::COIN,
  min_tx_fee: 10_000,
  min_relay_tx_fee: 10_000,
  free_tx_bytes: 1_000,
  dust: Bitcoin::CENT,
  per_dust_fee: false,
  bip34_height: 227931,
  dns_seeds: [],
  genesis_hash: "00028fe4651430d7a16d23972c8ff88b7824026b5d6fb964779303dc97175249",
  proof_of_work_limit: 0x1d00ffff,
  alert_pubkeys: [""],
  known_nodes: [],
  checkpoints: {}
}

Bitcoin.network = :odicoin

EM.run do
  defaults = Bitcoin::Node::Node::DEFAULT_CONFIG
  options = Bitcoin::Config.load(defaults, :blockchain)
  options[:max][:connections_out] = 0
  options[:max][:connections_in] = 1
  options[:max][:connections] = 1
  options[:log].each_key {|k| options[:log][k] = :debug }
  
  our_options = {
    listen: ['127.0.0.1', '6677'],
    network: 'odicoin',
    storage: 'utxo::sqlite:/'
  }

  options = options.merge(our_options)
#  exit

  their_options = {
    :network=>:bitcoin,
    :listen=>["127.0.0.1", "12345"],
    :connect=>[],
    :command=>["127.0.0.1", "9999"],
    :storage=>"utxo::sqlite://~/.bitcoin-ruby/<network>/blocks.db",
    :announce=>false,
    :external_port=>nil,
    :mode=>:full,
    :cache_head=>true,
    :index_nhash=>false,
    :index_p2sh_type=>false,
    :dns=>true,
    :epoll_limit=>10000,
    :epoll_user=>nil,
    :addr_file=>"~/.bitcoin-ruby/<network>/peers.json",
    :log=>{
      :network=>:info,
      :storage=>:info
    },
    :max=>{
      :connections_out=>8,
      :connections_in=>32,
      :connections=>8,
      :addr=>256,
      :queue=>501,
      :inv=>501,
      :inv_cache=>0,
      :unconfirmed=>100
    },
    :intervals=>{
      :queue=>1,
      :inv_queue=>1,
      :addrs=>5,
      :connect=>5,
      :relay=>0,
      :ping=>90
    },
    :import=>nil,
    :skip_validation=>false,
    :check_blocks=>1000,
    :connection_timeout=>10
  }

  puts options.inspect
  node = Bitcoin::Node::Node.new(options)
  node.run
end
