Vagrant.configure('2') do |config|
  config.vm.box                = 'secretescapes/smartos-base64'
  config.vm.box_version        = '1.0.0'
  config.vm.synced_folder      './vagrant', '/usbkey/user_home/vagrant/vagrant',
                               type: 'rsync',
                               owner: 'vagrant', group: 'vagrant',
                               disabled: false
  config.vm.synced_folder      '.', '/usbkey/user_home/vagrant/ruby-libv8-node',
                               type: 'rsync',
                               rsync__exclude: ['.vagrant/', 'vagrant/', 'src/', 'pkg/', 'vendor/', 'Gemfile.lock', '*.so', '*.bundle', 'tmp/'],
                               owner: 'vagrant', group: 'vagrant',
                               disabled: false
  config.ssh.insert_key        = false
  config.ssh.sudo_command      = '/usr/bin/pfexec %c'
  config.solaris11.suexec_cmd  = '/usr/bin/pfexec'
  config.solaris.suexec_cmd    = '/usr/bin/pfexec'
  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--memory', 4096]
    v.customize ['modifyvm', :id, '--cpus', 2]
  end
end
