require_relative 'cli'

unless ARGV.length == 4
    raise 'Missing screen name and port number command line arguments'
end

tmp1 = ARGV[0].to_s
tmp2 = ARGV[1].to_s
tmp3 = ARGV[2].to_i
tmp4 = ARGV[3].to_i

# 172.28.162.94 # TODO: Remove comment :S
puts "#{tmp1}, #{tmp2}, #{tmp3}, #{tmp4}"

ARGV.clear

cli = CLI.new(tmp1, tmp2, tmp3, tmp4)
cli.run