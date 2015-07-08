require 'bitcoin/blockchain'
require 'bitcoin/blockchain/backends'

chain = Bitcoin::Blockchain::Backends::Utxo.new(db: "sqlite://db/odicoin.db")

puts chain
