#encoding: utf-8
require './ruby-des'

@ary = []

def encrypt_string(string)
  string.flatten!
  key  = RubyDES::Block.new('hushhush')
  tmp_block = RubyDES::Block.new(string)
  encrypted = RubyDES::Ctx.new(tmp_block, key).encrypt
  decrypted = RubyDES::Ctx.new(encrypted, key).decrypt
  #puts encrypted.string
  #puts decrypted.string
  @ary << decrypted.string
  #p decrypted.string
  p tmp_block.bit_array.size
  p decrypted.bit_array.size
 
end

tmp_block = nil
tmp_string = []
chars_inc = 0
File.open('./code.txt', 'r') do |input_file|
  input_file.each_byte do |character|
    character = character.to_s(2).split('').map(&:to_i)
    if character.size < 8
      diff = 8 - character.size
      diff.times do
        character.insert(0, 0)
      end
    end           
    if chars_inc < 8
    #   #p chars_inc
    tmp_string << character
    chars_inc += 1
    else
      encrypt_string(tmp_string)
      chars_inc = 1
      tmp_string = []
      tmp_string << character
    end          
  end
  
  if tmp_string.length < 8
    (8 - tmp_string.length).times do
      tmp_string << [0,0,0,0,0,0,0,0]
    end   
  end
  encrypt_string(tmp_string)        
end
output_file = File.open("output.txt", "w+")
#p @ary.join.inspect
output_file.write(@ary.join) 
