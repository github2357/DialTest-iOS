# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

require 'motion-config-vars'
require 'motion-testflight'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.

  app.interface_orientations = [:portrait]

  app.frameworks += %w(CoreMotion QuartzCore)

  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false
  app.info_plist["UIStatusBarStyle"] = "UIStatusBarStyleBlackOpaque"

  app.pods do
    pod 'AFNetworking'
    pod 'SVProgressHUD'
  end

  app.release do
    app.name = 'DialTest'
  end

  app.development do
    app.name = 'DialTest-Test'

    app.entitlements['get-task-allow'] = true

    app.codesign_certificate = 'iPhone Developer: Travis Valentine (9P353S9D54)'

    app.provisioning_profile = '/Users/travisvalentine/personal/DialTest-iOS-cert/DialTest_1388544764.mobileprovision'
    app.entitlements['aps-environment'] = 'development'

    # Testflight credentials
    app.testflight do
      app.testflight.sdk = 'vendor/TestFlight'
      app.testflight.api_token  = "a4844ad184f8f310c2817f0e9e81787b_ODAwNTUxMjAxMi0xMi0yMyAwOToyNjowNy42MDI0NjY"
      app.testflight.team_token = "edce8455d12841c40e6efea2a9e05623_MzIxNDk4MjAxNC0wMS0wNyAyMjoxMjowNS4zNjk5MTg"
      app.testflight.app_token  = "4277c952-c3c5-4ca2-85bc-1e6bc25f33b3"
    end
  end
end
