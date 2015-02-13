#
# Cookbook Name:: chef-geoserver
# Recipe:: default
#
# Copyright (C) 2015 Stephane LII
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt::default"
include_recipe 'chef-geoserver::_tomcat'

package 'unzip' do
   action :install
end



directory node['chef-geoserver']['directory']['src'] do
   owner 'root'
   group 'root'
   mode '0755'
   action :create
   recursive true
end

remote_file node['chef-geoserver']['directory']['src'] + '/' + node['chef-geoserver']['name_geoserver'] do
   mode '0644'
   source node['chef-geoserver']['geoserver_link']
end


unzip_command = "unzip -u #{node['chef-geoserver']['directory']['src']}" + '/' + "#{node['chef-geoserver']['name_geoserver']}"
cp_geoserver_war = "cp #{node['chef-geoserver']['directory']['src']}" + '/' +  'geoserver.war' + ' ' + "#{node['tomcat']['webapp_dir']}"
unzip_command1 = "unzip -u #{node['chef-geoserver']['directory']['src']}" + '/' + "geoserver.war"
chmod = "chown -R tomcat7:tomcat7 #{node['tomcat']['webapp_dir']}" + "/geoserver"

directory node['tomcat']['webapp_dir'] + '/geoserver' do
   owner 'tomcat7'
   group 'tomcat7'
   mode '0755'
   action :create
   recursive true
end

bash 'unzip-deploy-geoserverwar' do
  user 'root'
  cwd node['chef-geoserver']['directory']['src']
  code <<-EOH
   #{unzip_command}
   cd /var/lib/tomcat7/webapps/geoserver
   #{unzip_command1}
   #{chmod}
  EOH
  notifies :restart, 'service[tomcat7]'
end
