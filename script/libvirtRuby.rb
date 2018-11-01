require 'libvirt'

system "clear"

def domainState_toString(flag)
  case flag
    when 0
        "NOSTATE"
    when 1
        "RUNNING"
    when 2
        "BLOCKED"
    when 3
        "PAUSED"
    when 4
        "SHUTDOWN"
    when 5
        "SHUTOFF"
    when 6
        "CRASHED"
    when 7
        "PMSUSPENDED"
    when 8
        "LAST"
    else
        "???"
  end
end

conn = Libvirt::open("qemu:///system")

# puts "list_domains:  #{conn.list_domains}\n"
# puts "list_all_domains:  #{conn.list_all_domains}\n"
# puts "list_defined_domains:  #{conn.list_defined_domains}\n"
# puts "Number of node devices: #{conn.num_of_nodedevices}\n"

#conn.list_nodedevices.each do |device|
#  nd = conn.lookup_nodedevice_by_name(device)

  # print some information about the device
#  puts "Nodedevice:"
#  puts " Name: #{nd.name}"
#  puts " Parent: #{nd.parent}"
#  puts " Number of Capabilities: #{nd.num_of_caps}"
#  puts " Capabilities: #{nd.list_caps.inspect}"
# end

conn.list_domains.each do |domain|                                                                                    
   vm = conn.lookup_domain_by_id(domain)
   puts "name: #{vm.name}\n"
   # puts "os_type: #{vm.os_type}\n"
   # puts "vcpu_count: #{vm.get_vcpus.count}\n"
   #  puts "max_memory: #{vm.max_memory/1024/1024}\n"
   #  puts "state: #{vm.state}\n" 
   puts "state: #{vm.info.state}:#{domainState_toString(vm.info.state)}, memory:  #{vm.info.memory/1024/1024}, cpu_num: #{vm.info.nr_virt_cpu}\n"
   
end


conn.close


=begin

begin
  # get the number of active and inactive interfaces and list them
  puts "Connection number of active interfaces: #{conn.num_of_interfaces}"
  puts "Connection number of inactive interfaces: #{conn.num_of_defined_interfaces}"
  puts "Connection interfaces:"
  active = conn.list_interfaces
  inactive = conn.list_defined_interfaces
  (active+inactive).each do |intname|
    puts " Interface #{intname}"
  end
rescue NoMethodError
  # skip this completely, since this compiled version of ruby-libvirt doesn't
  # support this method
rescue Libvirt::Error => e

=end 
