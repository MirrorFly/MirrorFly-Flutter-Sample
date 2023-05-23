#!/bin/bash

VERSION='2.0.9'
SHA1='f'

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

TEMPLATE="
Pod::Spec.new do |s|  
    s.name              = 'MirrorFlySDK'
    s.version           = \"$VERSION\"
    s.summary           = 'This repo to explore the cocopod and how to upload pod in public accessc'
    s.homepage          = 'https://github.com/MirrorFly/Mirrorfly-ios-framework'

    s.author            = { 'Vishvanath' => 'vishvanatheshwer.v.c@contus.in' }
    s.license      = { :type => 'Commercial', :file => 'LICENSE' }

    s.platform          = :ios, "12.1"
    # change the source location
    s.source            = { :git => 'https://github.com/MirrorFly/Mirrorfly-ios-framework.git', :tag => s.version.to_s } 

    s.swift_version = '4.0'
    s.requires_arc = true



    s.dependency 'libPhoneNumber-iOS', '0.9.15'
    s.dependency 'Alamofire', '5.5'
    s.dependency 'SocketRocket'
    s.dependency 'Socket.IO-Client-Swift', '15.2.0'
    s.dependency 'XMPPFramework/Swift'
    s.dependency 'RealmSwift' , '10.20.1'
    s.dependency 'GoogleWebRTC'


    s.ios.vendored_frameworks = 'SDK/MirrorFlySDK.xcframework'

   
end
"

echo "$TEMPLATE" > MirrorFlySDK.podspec

