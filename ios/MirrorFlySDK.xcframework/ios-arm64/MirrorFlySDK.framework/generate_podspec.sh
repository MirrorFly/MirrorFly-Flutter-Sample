#!/bin/bash

VERSION='5.8.2'
SHA1='v5.8.2'

while getopts v:s: flag
do
    case "${flag}" in
        v) VERSION=${OPTARG};;
        s) SHA1=${OPTARG};;
        *) error "Unexpected option ${flag}";;
    esac
done

echo $VERSION
if [ -z $VERSION ]; then
    echo 'Version is required'
fi

echo $SHA1
if [ -z $SHA1 ]; then
    echo 'shasum is required'
fi

TEMPLATE="Pod::Spec.new do |s|
    s.name              = 'MirrorFlySDK'
    s.version           = \"$VERSION\"
    s.summary           = 'This repo to explore the cocopod and how to upload pod in public accessc'
    s.homepage          = 'https://github.com/MirrorFly/Mirrorfly-ios-framework'
    s.author            = { 'Vishvanath' => 'vishvanatheshwer.v@contus.in','Vanitha' => 'vanitha.g@contus.in', }
    s.license      = { :type => 'Commercial', :file => 'LICENSE' }
    s.platform          = :ios, "12.1"
    s.source            = { :git => 'https://github.com/MirrorFly/Mirrorfly-ios-framework.git', :tag => s.version.to_s }
#    s.screenshots       = '','',''
#    s.social_media_url = ''
    s.swift_version = '5.0'
    s.requires_arc = true
    s.ios.deployment_target = '12.1'
    s.ios.vendored_frameworks = 'SDK/MirrorFlySDK.xcframework'
    s.documentation_url = 'https://www.mirrorfly.com/docs/chat/ios/v2/quick-start/'
    s.ios.frameworks = ['UIKit']
    s.dependency 'libPhoneNumber-iOS', '0.9.15'
    s.dependency 'Alamofire', '5.5.0'
    s.dependency 'SocketRocket', '0.6.0'
    s.dependency 'Socket.IO-Client-Swift', '15.2.0'
    s.dependency 'RealmSwift' , '10.20.1'
    s.dependency 'GoogleWebRTC'
    s.dependency 'CocoaLumberjack', '3.6.2'
    s.dependency 'XMPPFramework/Swift', '4.0.0'
    s.pod_target_xcconfig = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', 'IPHONEOS_DEPLOYMENT_TARGET' => '12.1',}
end
"

echo "$TEMPLATE" > MirrorFlySDK.podspec
