require 'bitcoin'

include Bitcoin::Builder

first_block = Bitcoin::Protocol::Block.from_file 'spec/bitcoin/fixtures/fake_chain/1.blk'
puts "Ur block: #{first_block.hash}"

key = Bitcoin::Key.generate
puts "Priv: #{key.priv}"
puts "Pub: #{key.pub}"

block = build_block do |b|
  b.time Time.now.to_i
  b.prev_block first_block.hash
  b.tx do |t|
    t.input { |i| i.coinbase }
    t.output { |o| o.value 50e8; o.script { |s| s.recipient key.addr } }
  end
end

puts "Next block: #{block.hash}"

File.open 'spec/bitcoin/fixtures/fake_chain/2.blk', 'w' do |f|
  f.write block.to_payload
end

receiver = Bitcoin::Key.generate

next_block = build_block do |b|
  b.time Time.now.to_i
  b.prev_block first_block.hash
  b.tx do |t|
#  t.input { |i| i.coinbase }
#    t.output { |o| o.value 50e8; o.script { |s| s.recipient key.addr } }
    t.input do |i|
      i.prev_out block.tx[0]
      i.prev_out_index 0
      i.signature_key key
    end

    t.output do |o|
      o.value 49e8
      o.script do |s|
        s.recipient receiver.addr
      end
    end
  end
end

File.open 'spec/bitcoin/fixtures/fake_chain/3.blk', 'w' do |f|
  f.write next_block.to_payload
end

puts "Receiver priv: #{receiver.priv}"
puts "Receiver pub: #{receiver.pub}"
