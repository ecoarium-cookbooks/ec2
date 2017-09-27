
if in_ec2?
  include_recipe "aws"
  aws = data_bag_item(:aws, :api)

	if node[:ec2].has_key?(:elastic_ip) && !node[:ec2][:elastic_ip].nil?
	  ec2_elastic_ip node[:ec2][:elastic_ip] do
	    aws_access_key aws[:key]
	    aws_secret_access_key aws[:secret]
	    ip node[:ec2][:elastic_ip]
	    action :associate
	  end
	end

  ec2_tag_resources node[:ec2][:tags][:Name] do
    tags node[:ec2][:tags]
    aws_access_key aws[:key]
    aws_secret_access_key aws[:secret]
    instance_id node['ec2']['instance_id']
  end

end
