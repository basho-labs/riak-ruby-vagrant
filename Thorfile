# encoding: utf-8

require 'bundler'
require 'bundler/setup'
require 'berkshelf/thor'

class Default < Thor
  desc 'update', "Update and install cookbooks"
  def update
    `berks update`
    invoke :install
  end

  desc 'install', "Install cookbooks"
  def install
    `berks install -p cookbooks`
  end
end
