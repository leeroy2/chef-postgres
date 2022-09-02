# frozen_string_literal: true

current_dir = File.dirname(__FILE__)
log_level :info
log_location STDOUT
chef_zero.enabled true
cookbook_path ["#{current_dir}/resources"]

knife[:secret_file] = File.expand_path('~/.kitchen/secret/encrypted_data_bag_secret')
knife[:editor] = 'vim'
