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

  app.release do
    app.identifier = 'com.dialtest.DialTest'
    app.name = 'DialTest'

    app.codesign_certificate = 'iPhone Distribution: Travis Valentine (GHXQWFB2B2)'

    app.entitlements['aps-environment'] = 'production'

    app.deployment_target = '7.0'
    app.version           = "1.0.0"

    app.provisioning_profile = '/Users/travisvalentine/personal/DialTest-iOS-cert/DialTest_Distribution.mobileprovision'
  end

  app.interface_orientations = [:portrait]
  app.device_family          = [:iphone]
  app.icons = ['icon_1024', 'icon_120', 'icon_80', 'icon_58', 'icon_50', 'icon_44']

  app.frameworks += %w(CoreMotion QuartzCore AdSupport Accounts Social)
  app.weak_frameworks += %w(AdSupport Accounts Social)

  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false
  app.info_plist["UIStatusBarStyle"] = "UIStatusBarStyleBlackOpaque"

  app.info_plist['FacebookAppID']    = "615135201874047"
  app.info_plist['CFBundleURLTypes'] = [
    {"CFBundleURLSchemes" => ["fb615135201874047"]}
  ]

  app.pods do
    pod 'AFNetworking'
    pod 'SVProgressHUD'
    pod 'Facebook-iOS-SDK'
  end

end
