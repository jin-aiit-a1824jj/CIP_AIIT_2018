#-*- coding: utf-8 -*-                                                                                  
require 'libvirt'
require 'rexml/document'
require 'active_record'
require 'mysql2'

ActiveRecord::Base.configurations = YAML.load_file(File.dirname(__FILE__) + '/dbyml.yml')
ActiveRecord::Base.establish_connection(:development)

class List < ActiveRecord::Base
end

class Find_vm_data

  def self.Get_data(name)
    return List.find_by(vm_name: name)
  end

end
