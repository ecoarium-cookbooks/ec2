define :ec2_elastic_ip do
	Chef::Log.info("Detected EC2 environment; associating elastic IP")

	_aws_access_key = params[:aws_access_key]
	_aws_secret_access_key = params[:aws_secret_access_key]
	Chef::Log.info("Associating current host with elastic IP: #{params[:ip]}")

	aws_elastic_ip "associate_#{params[:ip].gsub(/\./,'_')}_eip" do
		aws_access_key _aws_access_key
		aws_secret_access_key _aws_secret_access_key
		ip params[:ip]
		action :associate
	end
end
