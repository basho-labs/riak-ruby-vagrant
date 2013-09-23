# encoding: utf-8

require 'bundler'
require 'bundler/setup'
require 'berkshelf/thor'

class Default < Thor
  desc 'update', "Update and install cookbooks"
  def update
    system 'berks update'
    invoke :install
  end

  desc 'install', "Install cookbooks"
  def install
    system 'berks install -p cookbooks'
  end

  desc 'reprovision', "Update cookbooks and reprovision"
  def reprovision
    invoke :update
    system 'vagrant provision'
  end
end
