#-*- coding: utf-8 -*-

require 'rexml/document'
require 'securerandom'
require 'libvirt'
require 'time'
require 'active_record'
require 'mysql2'

ActiveRecord::Base.configurations = YAML.load_file('dbyml.yml')
ActiveRecord::Base.establish_connection(:development)

class List < ActiveRecord::Base
end

@ip_under3 = []

def push_add_ip_to_ip_under3()
 List.all.each do |d|
  v = d.vm_ip.from(12)
  #puts v
  @ip_under3.push(v.to_i)
 end
end

def leases_net_ip(name, cpu, memory, mac_addr)
 under3 = 0
 while true do
   under3 = rand(2..254)
   if(@ip_under3.find{ |v| v == under3 } == nil)
     break
   end
 end
 @ip_under3.push(under3)

 data = List.new
 data.vm_name = name
 data.vm_cpu = cpu.to_i
 data.vm_memory = memory.to_i
 data.vm_mac_addr = mac_addr
 data.vm_ip = "192.168.122." + under3.to_s
 data.save
end

#以下がmainコード

#画面をきれいに
system "clear"

puts "Input VM Name:"
vm_name = gets
# p vm_name.chomp!

puts "Input VM CPU number:"
vm_cpu_number = gets
# p vm_cpu_num_ber.chomp!

puts "Input VM MEMORY number: Unit=Kib ex)1GB = 1048576KB"
vm_memory = gets

#原本ファイルのパス指定 -domain xml edit
xml = File.expand_path(File.dirname(__FILE__)) + "/moto.xml"
doc = REXML::Document.new(open(xml).read)

#新しい名前更新
element_name = doc.elements['domain/name']
element_name.text = nil
element_name.add_text(vm_name.chomp!)
       
#新しいUUID更新
element_uuid = doc.elements['domain/uuid']
element_uuid.text = nil
element_uuid.add_text(SecureRandom.uuid)

#新しいmemory更新
element_memory = doc.elements["domain/memory unit='KiB'"]
element_memory.text = nil
element_memory.add_text(vm_memory.chomp!)
#                                                                                                                                                                    
element_memory_c = doc.elements["domain/currentMemory unit='KiB'"]
element_memory_c.text = nil
element_memory_c.add_text(vm_memory.chomp!)

#                                                                                                                                                                   
element_vcpu = doc.elements["domain/vcpu placement='static'"]
element_vcpu.text = nil
element_vcpu.add_text(vm_cpu_number.chomp!)

#
element_vol = doc.elements['domain/devices/disk/source']
element_vol.delete_attribute('file')
element_vol.add_attributes({"file"=>"/var/kvm/disk/kvm_centos7/"+vm_name+".qcow2"})

#新しいmac address                                                                                      
element_mac = doc.elements['domain/devices/interface/mac']
element_mac.delete_attribute('address')

# QEMU or KVM                                                                                          
mac = [0x52, 0x42, 0x00, Random.rand(0x7f), Random.rand(0xff), Random.rand(0xff)]
n_mac = (["%02x"] * 6).join(":") % mac
# puts n_mac
element_mac.add_attributes({"address"=>n_mac})


#新しいXMLとして保存
File.write(vm_name+".xml", doc) 
# puts vm_name + ".xml"


# -volume xml edit
xml = File.expand_path(File.dirname(__FILE__)) + "/vol_waku.xml"
doc = REXML::Document.new(open(xml).read)

#       
element_name = doc.elements['volume/name']
element_name.text = nil
element_name.add_text(vm_name + ".qcow2")

#       
element_key = doc.elements['volume/key']
element_key.text = nil
element_key.add_text("/var/kvm/disk/kvm_centos7/"+ vm_name +".qcow2")

#       
element_target_path = doc.elements['volume/target/path']
element_target_path.text = nil
element_target_path.add_text("/var/kvm/disk/kvm_centos7/"+ vm_name +".qcow2")

#新しいXMLとして保存
File.write("vol_"+vm_name+".xml", doc)
#puts "vol_" +  vm_name + ".xml"

#新しいIPを振り分けの支度
push_add_ip_to_ip_under3()
leases_net_ip(vm_name, vm_cpu_number.to_i, vm_memory.to_i, n_mac)

#
begin

 conn = Libvirt::open("qemu:///system")

 pool = conn.lookup_storage_pool_by_name("kvm_centos7") 
 clone_moto_vol = pool.lookup_volume_by_name("disk-origin.qcow2")

 puts "cloning volume  Wait a minute~"
 xml = File.expand_path(File.dirname(__FILE__)) + "/vol_"+vm_name+".xml"
 doc = REXML::Document.new(open(xml).read)
 vol = pool.create_volume_xml_from("#{doc}", clone_moto_vol, 0)
 pool.refresh

 puts "adding new mac address"
 net = conn.lookup_network_by_name("default")
 add_host = "<host mac='" + n_mac + "' name='" + vm_name  + "' ip='192.168.122." + @ip_under3.last.to_s + "' />"
 puts add_host
 net.update(3, 4, -1, add_host, 1)

 conn.create_domain_linux(File.read(File.expand_path(File.dirname(__FILE__)) + "/" + vm_name + ".xml"))
 dom = conn.lookup_domain_by_name(vm_name)
 puts "pending new vm! wait a second~"
 sleep(10)
 dom.reset(0)
 # puts dom.xml_desc 
 
 conn.close

rescue Libvirt::Error => e

  puts e

end

