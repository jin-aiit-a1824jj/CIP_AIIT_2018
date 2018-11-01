require 'libvirt'

puts "Input VM name:"
vm_name = gets
vm_name = vm_name.chomp!
puts vm_name

begin

 conn = Libvirt::open("qemu:///system")
 conn.list_domains.each do |domain|
    vm = conn.lookup_domain_by_id(domain)
    if(vm_name == vm.name)
      vm.shutdown
      vm.destroy
    end
 end
 conn.close

rescue Livbirt::Error => e

end
