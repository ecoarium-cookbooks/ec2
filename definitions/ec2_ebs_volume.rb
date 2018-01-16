
define :ec2_ebs_volume do
  Chef::Log.info("Detected EC2 environment: creating volume")

  _aws_access_key = params[:aws_access_key]
  _aws_secret_access_key = params[:aws_secret_access_key]
  _volume_name = params[:name]
  _volume_size = params[:volume_size]
  _volume_type = params[:volume_type]
  _volume_iops = params[:volume_iops]
  _volume_mount_path = params[:volume_mount_path]
  _volume_device = params[:volume_device]
  _volume_mount_point = params[:volume_mount_point]
  _fstype = params[:fstype]
  _fstype = :ext4 if _fstype.nil?

  _timeout = _volume_size * 100

  aws_ebs_volume _volume_name do
    aws_access_key _aws_access_key
    aws_secret_access_key _aws_secret_access_key
    size _volume_size
    volume_type _volume_type
    piops _volume_iops
    device _volume_device
    action [ :create, :attach ]
  end

  format_drive _volume_mount_point do
    type _fstype
    timeout _timeout
  end

  directory "#{_volume_mount_path}" do
    mode "0755"
    recursive true
  end

  mount_resource = mount("#{_volume_mount_path}") do
    device "#{_volume_mount_point}"
    options "rw noatime"
    fstype _fstype.to_s
    action [ :enable, :mount ]
    not_if "cat /proc/mounts |grep /mnt/#{_volume_mount_path}"
  end

  unless node[:ec2][:tags].nil?
    ec2_tag_resources "#{node[:ec2][:tags][:Name]}-#{_volume_device}" do
      tags node[:ec2][:tags]
      aws_access_key _aws_access_key
      aws_secret_access_key _aws_secret_access_key
      instance_id node['ec2']['instance_id']
      only_if { mount_resource.updated_by_last_action? }
    end
  end

end
