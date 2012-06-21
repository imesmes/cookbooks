# Basic packages
package "curl"
package "zsh"
package "python-software-properties"

# Required for sending emails
package "telnet"
package "postfix"

# Required packages for ruby development
package "libncurses5-dev"
package "libreadline5"
package "libreadline5-dev"
package "libreadline6" 
package "libreadline6-dev" 
package "zlib1g" 
package "zlib1g-dev" 
package "libssl-dev" 
package "libyaml-dev" 
package "libsqlite3-dev" 
package "sqlite3" 
package "libxml2-dev" 
package "libxslt-dev" 
package "autoconf" 
package "libc6-dev" 
package "ncurses-dev" 
package "automake" 
package "libtool" 
package "bison" 
package "subversion"

# Required packages for wkhtmltopdf
package "fontconfig"

# Create deployer user
user node[:user][:name] do
  password node[:user][:password]
  gid "admin"
  home "/home/#{node[:user][:name]}"
  supports manage_home: true
  shell "/bin/zsh"
end

# Include zsh configuration
template "/home/#{node[:user][:name]}/.zshrc" do
  source "zshrc.erb"
  owner node[:user][:name]
end

# Install nginx and add example site
include_recipe "nginx::source"

directory "/home/#{node[:user][:name]}/example" do
  owner node[:user][:name]
end

file "/home/#{node[:user][:name]}/example/index.html" do
  owner node[:user][:name]
  content "<h1>Hello World</h1>"
end

file "#{node[:nginx][:dir]}/sites-available/example" do
  content "server { root /home/#{node[:user][:name]}/example; }"
end

nginx_site "example"

# Install postgresql
include_recipe "postgresql::server"

# Install nodejs for Rails assets pipeline
include_recipe "nodejs"

# Install rvm for a specific user
node['rvm']['user_installs'] = [
  {
    'user' => node[:user][:name],
    'default_ruby' => '1.9.3',
    'rubies' => ['1.9.3']
  }
]
include_recipe "rvm::user"
