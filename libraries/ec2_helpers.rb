require 'open-uri'

class Chef
  class Recipe

    def in_ec2?
      if !node[:ec2].nil? and !node[:ec2][:mock].nil? and !node[:ec2][:mock][:in_ec2?].nil?
          return node[:ec2][:mock][:in_ec2?]
      end
      instance_id = nil

      Timeout.timeout(2) do
        instance_id = open('http://169.254.169.254/latest/meta-data/instance-id'){|f| f.gets}
      end

      if instance_id.nil?
        return false
      end

      node.override['ec2']['instance_id'] = instance_id
      return true

      rescue
        return false
    end

  end
end
