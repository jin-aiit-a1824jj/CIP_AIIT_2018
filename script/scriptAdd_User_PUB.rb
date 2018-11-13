# coding:utf-8
require 'timeout'

system "clear"

def ssh(private_ip, command, dump=false)
  dev_null = dump ? '' : '>& /dev/null'
  one_liner = "sshpass -p 'admin' ssh -o 'StrictHostKeyChecking no' -i private-key "+ "root@#{private_ip} '#{command}'"+dev_null
  print "Execute: #{one_liner}\n" if dump
  system one_liner
end

def scp(private_ip, command, dump=false)
  one_liner = "sshpass -p 'admin' scp "+ "root@#{private_ip}:#{command}"
  print "Execute: #{one_liner}\n" if dump
  system one_liner
end


#以下がmainコード

code = false
ip = '192.168.122.119'
puts "Input user_name :"
user_name = gets.chomp!

command1 = "adduser #{user_name}"
command2 = "mkdir /home/#{user_name}/.ssh"
command3 = "ssh-keygen -q -t rsa -C 'sample-commant' -N '12345' -f '/home/#{user_name}/.ssh/#{user_name}-access-key'"   #  % ["sample comment", "kari-key-name"]
command4 = "chmod 700 /home/#{user_name}/.ssh"
command5 = "cp /home/#{user_name}/.ssh/#{user_name}-access-key.pub /home/#{user_name}/.ssh/authorized_keys"
command6 = "chmod 600 /home/#{user_name}/.ssh/authorized_keys"
command7 = "chown -R #{user_name}:#{user_name} /home/#{user_name}/.ssh"

command8 = "/home/#{user_name}/.ssh/#{user_name}-access-key /home/JIN/"

begin

  timeout(5) do
    code = ssh(ip, command1, true)
  end
  print (code ? "Success.\n" : "Failure. (Command1 Error)\n")
  
  timeout(5) do
    code = ssh(ip, command2, true)
  end
  print (code ? "Success.\n" : "Failure. (Command2 Error)\n")

  timeout(5) do
    code = ssh(ip, command3, true)
  end
  print (code ? "Success.\n" : "Failure. (Command3 Error)\n")

 timeout(5) do
    code = ssh(ip, command4, true)
  end
  print (code ? "Success.\n" : "Failure. (Command4 Error)\n")

  timeout(5) do
    code = ssh(ip, command5, true)
  end
  print (code ? "Success.\n" : "Failure. (Command5 Error)\n")

  timeout(5) do
    code = ssh(ip, command6, true)
  end
  print (code ? "Success.\n" : "Failure. (Command6 Error)\n")

 timeout(5) do
    code = ssh(ip, command7, true)
  end
  print (code ? "Success.\n" : "Failure. (Command7 Error)\n")

   timeout(5) do
    code = scp(ip, command8, true)
  end
  print (code ? "Success.\n" : "Failure. (Command8 Error)\n")

  print "try ssh access↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\n"
  print "ssh #{user_name}@#{ip} -i #{user_name}-access-key \n"
  print "ssh key passphrase : 12345 \n" 
rescue Timeout::Error => e
  print "Failure. (Timeout)\n"
end
