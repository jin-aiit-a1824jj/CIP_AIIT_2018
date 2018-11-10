#-*- coding: utf-8 -*-

require 'libvirt'
require 'rexml/document'
require 'active_record'
require 'mysql2'

ActiveRecord::Base.configurations = YAML.load_file('dbyml.yml')
ActiveRecord::Base.establish_connection(:development)

class List < ActiveRecord::Base
end

@ip = ""

def remove_db(name)
 data = List.find_by(vm_name: name)
 if(data != nil)
   @ip = data.vm_ip
   data.destroy
 end
end

#以下がmainコード

#画面をきれいに                                                                                        
system "clear"

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
 puts "removing DB"
 remove_db(vm_name) 

 #
 puts "removing dchp ip"
 net = conn.lookup_network_by_name("default")
 #puts net.xml_desc(0)
 
 rhost = "<host mac='" + mac_addr[0].to_s + "' name='" + "#{vm_name}" + "' ip='" + "#{@ip}" + "' />"
 puts rhost
 net.update(2, 4, -1, rhost, 1) 
 
 #
 conn.close
 # sleep(10)
 puts "remove vm complete!"
 
rescue Livbirt::Error => e

  puts e

end
