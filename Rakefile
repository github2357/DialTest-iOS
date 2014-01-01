# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'DialTest-iOS'

  app.interface_orientations = [:portrait]

  app.frameworks += %w(CoreMotion)

  app.pods do
    pod 'AFNetworking'
  end

  app.development do
    app.entitlements['get-task-allow'] = true

    app.codesign_certificate = 'iPhone Developer: Travis Valentine (9P353S9D54)'

    app.provisioning_profile = '/Users/travisvalentine/personal/DialTest-iOS-cert/DialTest_1388544764.mobileprovision'
    app.entitlements['aps-environment'] = 'development'
  end
end
