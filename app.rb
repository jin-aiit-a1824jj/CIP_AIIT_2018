# app.rb
require 'sinatra'
require 'sinatra/base'
require 'json'
# require 'sudo'
require 'open3'
require 'sinatra/reloader'
require 'libvirt'

# $stdout.sync = true

get '/' do
   redirect to("test_static_page.html")
end

get '/this' do
  'Hello world! this!'
  article = {
      id: 1,
      title: "today's dialy",
      content: "It's a sunny day."
  }
 
  article.to_json

end

get '/func1' do
  result = open("| ps")

  #print result.class # => IO
  
  data = {"data" => []}

  while !result.eof
   puts "#{result.gets}"
   e = {"value" => result.gets}
   data["data"].push(e)
  end

  result.close
  data.to_json
end

def func(cmd)
  puts "#{cmd}" 
end

get "/func2/:cmd" do
"Hello!"
# "#{params['cmd']}"
conn = Libvirt::open("qemu:///system")
puts conn.list_domains


# puts conn.capabilities
# "#{conn}"

#conn.list_defined_domains.each{|dom_name|
#    vm = conn.lookup_domain_by_name(dom_name)
#    puts "#{vm.name}"
#}

# dom = conn.lookup_domain_by_name("kvm_centos7")
#puts dom
# "#{dom.name}\n"
# "#{dom.job_info}\n"
# dom.info
# File.expand_path(File.dirname(__FILE__)) + "/public/test.sh"
# "sudo -S virsh list"

#Open3.popen3(File.expand_path(File.dirname(__FILE__)) + "/public/test.sh") do |i, o, e, w|
#    o.each do |line| puts "#{"stdout:" + line}" end
#    o.close

#    e.each do |line| puts "#{"error:" + line}" end
#    e.close
#end

#/var/www/test_sinatra/public/test.sh  

# func("#{params['cmd']}")
# result = open(command)
# data = {"data" => []}
 
# while !result.eof
#   puts "#{result.gets}"
#   e = {"value" => result.gets}
#   data["data"].push(e)
#  end

#  result.close 
#  data.go_json
 
end


class Stream
  def each
    100.times { |i| yield "#{i}\n" }
  end
end

get "/func3" do
  Stream.new
end

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

get "/func4" do
  begin
    data = {"data" => []}
    
    conn = Libvirt::open("qemu:///system")
    conn.list_domains.each do |domain|
      vm = conn.lookup_domain_by_id(domain)
      puts "name: #{vm.name}\n"  
      puts "state: #{vm.info.state}:#{domainState_toString(vm.info.state)}, memory:  #{vm.info.memory/1024/1024}, cpu_num: #{vm.info.nr_virt_cpu}\n"
    
      e = {"name" => vm.name,
           "state" => domainState_toString(vm.info.state),
           "memory" => vm.info.memory/1024/1024,
           "cpu" => vm.info.nr_virt_cpu}
      
      data["data"].push(e)
    end
    conn.close
    data.to_json
    
  @raw = data["data"]
  erb :test_Erb
  rescue Libvirt::Error => e
 end

end

