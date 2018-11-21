# -*- coding: utf-8 -*-

require 'sinatra'
require 'sinatra/base'
require 'json'
require 'sinatra/reloader'
require 'libvirt'

require File.expand_path(File.dirname(__FILE__) + '/script/scriptInstall.rb')
require File.expand_path(File.dirname(__FILE__) + '/script/scriptAdd_User_PUB.rb')
require File.expand_path(File.dirname(__FILE__) + '/script/scriptRemove.rb')
require File.expand_path(File.dirname(__FILE__) + '/script/scriptSearchDB.rb')

#タイトル画面（偽装）
get '/' do
   redirect to("test_static_page.html")
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

#Vmの状態を呼ぶ
get "/func_vm_status" do
  begin
    data = {"data" => []}
    
    conn = Libvirt::open("qemu:///system")

    conn.list_domains.each do |domain|
      vm = conn.lookup_domain_by_id(domain)
     #  puts "name: #{vm.name}\n"  
     #  puts "state: #{vm.info.state}:#{domainState_toString(vm.info.state)}, memory:  #{vm.info.memory/1024/1024}, cpu_num: #{vm.info.nr_virt_cpu}\n"
    
      e = {"name" => vm.name,
           "state" => domainState_toString(vm.info.state),
           "memory" => vm.info.memory/1024/1024,
           "cpu" => vm.info.nr_virt_cpu}   
      data["data"].push(e)
    end

    conn.list_defined_domains.each do |domain|
      vm = conn.lookup_domain_by_name(domain)
     #  puts "name: #{vm.name}\n"
     #  puts "state: #{vm.info.state}:#{domainState_toString(vm.info.state)}, memory:  #{vm.info.memory/1024/1024}, cpu_num: #{vm.info.nr_virt_cpu}\n"                                                                          

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

post "/vm-do/:cmd/:vm_name" do
  
  cmd = "#{params['cmd']}"
  vm_name = "#{params['vm_name']}"
  conn = Libvirt::open("qemu:///system")
  
  begin
      vm = conn.lookup_domain_by_name(vm_name)
      puts "/vm-do/#{params['cmd']}/#{vm.name}\n"
      
        case cmd
          when "start"
             # vm.create
          when "shutdown"
             # vm.shutdown(1)
          when "reboot"
              vm.reset
          when "destroy"
             #  vm.destroy
          else
              puts "wakaranai: #{vm}"
        end

 rescue Libvirt::Error => e
 end
 
 conn.close
 
 sleep(5)
 redirect "/func_vm_status"
end

get '/new_vm_form' do
  erb :vm_new_form
end

post '/test_param' do
  params
  puts params["vm_name"]
  puts params["vm_cpu"]
  puts params["vm_memory"]
  status 200
end


#新しいVM起動させる
post '/new_vm' do

#   reqData = JSON.parse(request.body.read.to_s) 
#   vm_name = reqData['vm_name']
#   vm_cpu = reqData['vm_cpu']
#   vm_memory = reqData['vm_memory']  

   vm_name =  params["vm_name"]
   vm_cpu = params["vm_cpu"]
   vm_memory =  params["vm_memory"]

   New_Vm.Make_New_Vm(vm_name, vm_cpu, vm_memory)
   puts "vm_cloning is over"
  
   #vmが立ち上がることを待つ
   sleep(30)
  
   New_Pub.Make_new_pub(vm_name)
   puts "vm_publickey_generate_over!"

   redirect "/new_vm_result?vm_name=#{vm_name}"

   # status 202
   # redirect "/func_vm_status"
   # call env.merge('PATH_INFO' => '/new_pub') 
end

get '/new_vm_result' do
  
   data = Find_vm_data.Get_data(params["vm_name"])

   @vm_name = data.vm_name
   @vm_cpu = data.vm_cpu
   @vm_memory = data.vm_memory
   @vm_ip = data.vm_ip
   # @raw = ""

   erb :vm_new_result
end

get '/test_param2' do
  redirect "/new_vm_result?test=#{params["test"]}"
end

post '/delete_vm/:vm_name' do

   vm_name = "#{params['vm_name']}"

   Delete_vm.Remove_vm(vm_name)
   puts "delete_vm_over!"

   status 202
   redirect "func_vm_status"
end




=begin
# 最新トピック10件分を取得
get '/topics.json' do
  content_type :json, :charset => 'utf-8'
  topics = Topic.order("created_at DESC").limit(10)
  topics.to_json(:root => false)
end

# トピック投稿
post '/topic' do
  # リクエスト解析
  reqData = JSON.parse(request.body.read.to_s) 
  title = reqData['title']
  description = reqData['description']

  # データ保存
  # topic = Topic.new
  # topic.title = title
  # topic.description = description
  # topic.save

  # レスポンスコード
  status 202  
end
=end
