#encoding: utf-8
require './ruby-des'

@ary = []

def encrypt_string(string)
  key  = RubyDES::Block.new('hushhush')
  tmp_block = RubyDES::Block.new(string.force_encoding('utf-8'))
  encrypted = RubyDES::Ctx.new(tmp_block, key).encrypt
  decrypted = RubyDES::Ctx.new(encrypted, key).decrypt
  #puts encrypted.string
  #puts decrypted.string
  @ary << decrypted.string.force_encoding('utf-8')
  #p decrypted.string
  p tmp_block.bit_array.size
  p decrypted.bit_array.size
 
end

tmp_block = nil
tmp_string = ''
chars_inc = 0
File.open('./code.txt', 'r') do |input_file|
  input_file.each_char do |character|
    if chars_inc < 8
      #p chars_inc
      tmp_string += character
      chars_inc += 1
    else
      encrypt_string(tmp_string)
      chars_inc = 1
      tmp_string = ''
      tmp_string += character
    end          
  end
  p tmp_string.length
  if tmp_string.length < 8
    tmp_string += ' ' * (8 - tmp_string.length)
  end
  encrypt_string(tmp_string)        
end
output_file = File.open("output.txt", "w+")
#p @ary.join.inspect
output_file.write(@ary.join) 
