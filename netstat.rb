!#/usr/bin/env ruby

# extended from http://snippets.dzone.com/tag/netstat courtesy of Krzysztof Wilczynski 
# https://github.com/kwilczynski


require 'optparse'
options = {}

protocols = ["tcp","udp"]
OptionParser.new do |opts|
  opts.banner = "Usage: netstat.rb [options]"
  
  protocols.each do |protocol|
    @protocol = []
    opts.on( "-#{protocol[0,1]}", '--'+ protocol, "show #{protocol} ports" ) do |option|
      @protocol << protocol if option
    end
    @protocol = protocols if @protocol.empty?
  end
  options[:verbose] = false
  opts.on( '-v', '--verbose', 'verbose output' ) do
    options[:verbose] = true
  end
end.parse!





TCP_STATES = {
  '00' => 'UNKNOWN',  # Bad state ... Impossible to achieve ...
  'FF' => 'UNKNOWN',  # Bad state ... Impossible to achieve ...
  '01' => 'ESTABLISHED',
  '02' => 'SYN_SENT',
  '03' => 'SYN_RECV',
  '04' => 'FIN_WAIT1',
  '05' => 'FIN_WAIT2',
  '06' => 'TIME_WAIT',
  '07' => 'CLOSE',
  '08' => 'CLOSE_WAIT',
  '09' => 'LAST_ACK',
  '0A' => 'LISTEN',
  '0B' => 'CLOSING'
}

SINGLE_ENTRY_PATTERN = Regexp.new(
  /^\s*\d+:\s+(.{8}):(.{4})\s+(.{8}):(.{4})\s+(.{2})/
)



@protocol.each do |protocol|
  if options[:verbose]
    puts "#{protocol}:\n"
  end
  File.open('/proc/net/' + protocol).each do |i|
    i = i.strip
    if match = i.match(SINGLE_ENTRY_PATTERN)

      local_IP = match[1].to_i(16)
      local_IP = [local_IP].pack("N").unpack("C4").reverse.join('.')

      local_port = match[2].to_i(16)

      remote_IP = match[3].to_i(16)
      remote_IP = [remote_IP].pack("N").unpack("C4").reverse.join('.')

      remote_port = match[4].to_i(16)

      connection_state = match[5]
      connection_state = TCP_STATES[connection_state]

      if options[:verbose]
        puts "#{local_IP}:#{local_port} " +
         "#{remote_IP}:#{remote_port} #{connection_state}"
      else
         puts "#{local_IP}:#{local_port}"
      end
    end
  end
end
exit(0)
