
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

  ebs_volume_resource = aws_ebs_volume('fake') do
    aws_access_key _aws_access_key
    aws_secret_access_key _aws_secret_access_key
    action :nothing
  end

  ebs_volume_provider = ebs_volume_resource.provider_for_action(:create)

  volumes_result = ebs_volume_provider.ec2.describe_volumes(
    filters: [
      { name: 'attachment.instance-id', values: [params[:instance_id]] },
    ]
  )

	volumes_result.volumes.each do |volume|
		volume_tags = {} || params[:tags]
		volume_tags["Name"] = "#{params[:name]}- #{volume.attachments.first.device}"

	  aws_resource_tag volume.volume_id do
	    aws_access_key _aws_access_key
	    aws_secret_access_key _aws_secret_access_key
	    tags(volume_tags)
	    action :update
	  end
	end
end
