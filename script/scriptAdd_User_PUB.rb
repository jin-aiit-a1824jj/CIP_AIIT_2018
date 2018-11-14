#-*- coding: utf-8 -*-  

require 'timeout'
require 'active_record'
require 'mysql2'

ActiveRecord::Base.configurations = YAML.load_file(File.dirname(__FILE__) + '/dbyml.yml')
ActiveRecord::Base.establish_connection(:development)

class List < ActiveRecord::Base
end

def ssh(private_ip, command, dump=false)
  dev_null = dump ? '' : '>& /dev/null'
  one_liner = "sshpass -p 'admin' ssh -o 'StrictHostKeyChecking no' -i private-key -p 22 -t -t -t  "+ "root@#{private_ip} '#{command}'"+dev_null
  print "Execute: #{one_liner}\n" if dump
  system one_liner
end

def scp(private_ip, command, dump=false)
  one_liner = "sshpass -p 'admin' scp -o 'StrictHostKeyChecking no' "+ "root@#{private_ip}:#{command}"
  print "Execute: #{one_liner}\n" if dump
  system one_liner
end

def getIp(v_name)
  data = List.find_by(vm_name: v_name)
  if(data == nil)
    return nil
  end
  return data.vm_ip
end

def make_pub(v_name, v_ip)

  code = false
  ip = v_ip
  user_name = v_name

  command1 = "adduser #{user_name}"
  command2 = "mkdir /home/#{user_name}/.ssh"
  command3 = "ssh-keygen -q -t rsa -C 'sample-commant' -N '12345' -f '/home/#{user_name}/.ssh/#{user_name}-access-key'"  
  command4 = "chmod 700 /home/#{user_name}/.ssh"
  command5 = "cp /home/#{user_name}/.ssh/#{user_name}-access-key.pub /home/#{user_name}/.ssh/authorized_keys"
  command6 = "chmod 600 /home/#{user_name}/.ssh/authorized_keys"
  command7 = "chown -R #{user_name}:#{user_name} /home/#{user_name}/.ssh"

  command8 = "/home/#{user_name}/.ssh/#{user_name}-access-key /var/www/test_sinatra/public"

  t_out = 60

  begin

    timeout(t_out) do
      code = ssh(ip, command1, true)
    end
    print (code ? "Success.\n" : "Failure. (Command1 Error)\n")
  
    timeout(t_out) do
      code = ssh(ip, command2, true)
    end
    print (code ? "Success.\n" : "Failure. (Command2 Error)\n")

    timeout(t_out) do
      code = ssh(ip, command3, true)
    end
    print (code ? "Success.\n" : "Failure. (Command3 Error)\n")

    timeout(t_out) do
      code = ssh(ip, command4, true)
    end
    print (code ? "Success.\n" : "Failure. (Command4 Error)\n")

    timeout(t_out) do
      code = ssh(ip, command5, true)
    end
    print (code ? "Success.\n" : "Failure. (Command5 Error)\n")

    timeout(t_out) do
      code = ssh(ip, command6, true)
    end
    print (code ? "Success.\n" : "Failure. (Command6 Error)\n")

    timeout(t_out) do
      code = ssh(ip, command7, true)
    end
    print (code ? "Success.\n" : "Failure. (Command7 Error)\n")

    timeout(t_out) do
      code = scp(ip, command8, true)
    end
    print (code ? "Success.\n" : "Failure. (Command8 Error)\n")

    print "try ssh access↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\n"
    print "ssh #{user_name}@#{ip} -i #{user_name}-access-key \n"
    print "ssh key passphrase : 12345 \n" 
  rescue Timeout::Error => e
    print "Failure. (Timeout)\n"
  end

end

class New_Pub

  def self.Make_new_pub(v_name)
    v_ip = getIp(v_name)
    if(v_ip == nil)
      return
    end
    make_pub(v_name, v_ip)
  end

  def self.dump()
    return "scriptadduser_pub.rb"
  end

end
