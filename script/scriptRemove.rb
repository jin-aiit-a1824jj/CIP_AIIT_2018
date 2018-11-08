require 'libvirt'
require 'rexml/document'

puts "Input VM name:"
vm_name = gets
vm_name = vm_name.chomp!
puts vm_name

begin

 puts "vm destorying~"
 conn = Libvirt::open("qemu:///system")
 vm = conn.lookup_domain_by_name(vm_name)
 
 # puts vm.xml_desc
 doc = REXML::Document.new(vm.xml_desc)
 element_mac = doc.elements['domain/devices/interface/mac']
 # puts element_mac.attributes.values 
 mac_addr = element_mac.attributes.values

 vm.shutdown
 vm.destroy
 
 #
 sleep(10)
 puts "volume deleting~"
 pool = conn.lookup_storage_pool_by_name("kvm_centos7") 
 vol = pool.lookup_volume_by_name(vm_name + ".qcow2")
 vol.delete 
 pool.refresh
 
 #
 puts "removing dchp ip"
 net = conn.lookup_network_by_name("default")
 add_host = "<host mac='" + mac_addr + "' name='" + vm_name  + "' ip='192.168.122.100' />"
 net.update(2, 4, -1, add_host, 1) 
 sleep(10)

 #
 conn.close
 puts "remove vm complete!"
rescue Livbirt::Error => e
  puts e
end
