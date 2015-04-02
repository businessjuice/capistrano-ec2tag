require 'capistrano'
require 'aws-sdk'

module Capistrano
  module Ec2tag
    def self.extend(configuration)
      configuration.load do
        Capistrano::Configuration.instance.load do
          _cset(:access_key_id, ENV['AWS_ACCESS_KEY_ID'])
          _cset(:secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])

          def tag(which, *args)
            @ec2 ||= Aws::EC2::Resource.new({access_key_id: fetch(:aws_access_key_id), secret_access_key: fetch(:aws_secret_access_key)}.merge! fetch(:aws_params, {}))

            @ec2.instances.find_all{|i| i.tags.any?{|t| t.key == 'deploy' && t.value == which}}.each do |instance|
              server instance.public_ip_address || instance.private_ip_address, *args if instance.state.name == 'running'
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Ec2tag.extend(Capistrano::Configuration.instance)
end

