#-*- coding: utf-8 -*-

require 'rexml/document'
require 'securerandom'
require 'libvirt'
require 'time'

#画面をきれいに
system "clear"

puts "Input VM Name:"
vm_name = gets
# p vm_name.chomp!

puts "Input VM CPU number:"
vm_cpu_number = gets
# p vm_cpu_num_ber.chomp!

puts "Input VM MEMORY number:"
vm_memory = gets

#原本ファイルのパス指定 -domain xml edit
xml = File.expand_path(File.dirname(__FILE__)) + "/moto.xml"
doc = REXML::Document.new(open(xml).read)

#
element_name = doc.elements['domain/name']
element_name.text = nil
element_name.add_text(vm_name.chomp!)
       
#
element_uuid = doc.elements['domain/uuid']
element_uuid.text = nil
element_uuid.add_text(SecureRandom.uuid)

#
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

#
begin

 conn = Libvirt::open("qemu:///system")

 pool = conn.lookup_storage_pool_by_name("kvm_centos7") 
 clone_moto_vol = pool.lookup_volume_by_name("disk-origin.qcow2")

 xml = File.expand_path(File.dirname(__FILE__)) + "/vol_"+vm_name+".xml"
 doc = REXML::Document.new(open(xml).read)
 vol = pool.create_volume_xml_from("#{doc}", clone_moto_vol, 0)
 puts "Wait a minute~"
 pool.refresh
 
 conn.create_domain_linux(File.read(File.expand_path(File.dirname(__FILE__)) + "/" + vm_name + ".xml"))
 dom = conn.lookup_domain_by_name(vm_name)
 # puts dom.xml_desc 
 

 conn.close

rescue Livbirt::Error => e

  puts e

end

