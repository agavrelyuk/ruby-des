#encoding: utf-8
require './ruby-des'

@key = RubyDES::Block.new("kerouac!")
def set_key(block)
  @key = RubyDES::Block.new(block)
end

def get_key
  @key
end

@output_encrypted = "encrypted.xxx"
@output_decrypted = "decrypted.txt"
def set_output(target, filename)
  if target == :encrypt
    @output_encrypted = filename
  elsif target == :decrypt
    @output_decrypted = filename
  else
    raise "Wrong target"
  end  
end       

def get_output(target)
  if target == :encrypt
    @output_encrypted
  elsif target == :decrypt
    @output_decrypted
  else
    raise "Wrong target"
  end  
end      



def encrypt_block(block)
  block.flatten!
  tmp_block = RubyDES::Block.new(block)
  encrypted = RubyDES::Ctx.new(tmp_block, get_key).encrypt
  File.open(get_output(:encrypt), 'a+').write(encrypted.string)
end

def decrypt_block(block)
  block.flatten!
  tmp_block = RubyDES::Block.new(block)
  decrypted = RubyDES::Ctx.new(tmp_block, get_key).decrypt
  File.open(get_output(:decrypt), 'a+').write(decrypted.string)
end

def do_file( options = { filename: '', action: '' } )
  raise "No filename given" if options[:filename].length.zero?
  
  preset_actions = [:read_key, :encrypt, :decrypt]
  action = (preset_actions & [options[:action]]).size.zero? ? '' : options[:action]
  raise "Wrong action" if action.length.zero?  
  
  current_block = []
  bytes_count = 0
  File.open(options[:filename], 'r') do |input_file|
    
    input_file.each_byte do |byte|
      
      byte = byte.to_s(2).split('').map(&:to_i)
      
      # adding zero bits to equal all bit views by length  
      diff = 8 - byte.size      
      diff.times do
        byte.insert(0, 0)
      end
            
      if bytes_count < 8
        current_block << byte
        bytes_count += 1
      else
        case action
        when :read_key
          set_key(current_block)
        when :encrypt
          encrypt_block(current_block)
        when :decrypt
          decrypt_block(current_block)
        end    
        bytes_count = 1
        current_block = []
        current_block << byte
      end
                
    end
    
    byte_size_diff = 8 - current_block.size
    byte_size_diff.times do
        current_block << [0,0,0,0,0,0,0,0]
    end
      
    case action
    when :read_key
      set_key(current_block)
    when :encrypt
      encrypt_block(current_block)
    when :decrypt
      decrypt_block(current_block)
    end 
    
  end
end  


def read_keyfile(filename)
  do_file(filename: filename, action: set_key)
end


def run_interface
  puts "\n"*5

  puts "############################"
  puts "Ruby DES encryptor/decryptor"
  puts "############################"
  
  puts "\nremember that DES is deprecated"

  puts "\n"*2

  puts "Availiable actions\n1 - encrypt\n2 - decrypt"

  puts "\n"

  print "Choise: "
  action = gets.to_i

  if action == 1
    action = :encrypt
  elsif action == 2
    action = :decrypt
  else
    puts "Wrong number!"
    return    
  end    

  print "Enter filename of source: "
  source = gets.chomp 
  if source.length.zero?
    puts "Empty filename!"
    return
  end  
  print "Enter filename of key or blank for default: "
  key_filename = gets.chomp
  set_key read_keyfile(key_filename) unless key_filename.length.zero?

  print "Enter filename of output or blank for default: "
  output_filename = gets.chomp
  set_output(action, output_filename) unless output_filename.length.zero?

  do_file(filename: source, action: action)
end

run_interface