rm *.gem
gem uninstall -a vagrant-hostmanager
gem build *.gemspec
gem install *.gem
vagrant plugin install vagrant-hostmanager
