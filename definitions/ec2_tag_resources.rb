
define :ec2_tag_resources do
  instance_tags = {} || params[:tags]
  instance_tags["Name"] = params[:name]

  _aws_access_key = params[:aws_access_key]
  _aws_secret_access_key = params[:aws_secret_access_key]

	aws_resource_tag params[:instance_id] do
	  aws_access_key _aws_access_key
	  aws_secret_access_key _aws_secret_access_key
	  tags(instance_tags)
	end 

	ec2 = RightAws::Ec2.new(_aws_access_key, _aws_secret_access_key)
	  
	instance_info = ec2.describe_instances(params[:instance_id])

	instance_info[0][:block_device_mappings].each do |device|
		volume_tags = {} || params[:tags]
		volume_tags["Name"] = "#{params[:name]}- #{device[:device_name]}"
		
	  aws_resource_tag device[:ebs_volume_id] do
	    aws_access_key _aws_access_key
	    aws_secret_access_key _aws_secret_access_key
	    tags(volume_tags)
	    action :update
	  end
	end
end