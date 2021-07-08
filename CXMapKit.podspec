#
# Be sure to run `pod lib lint CXMapKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do | s |
    s.name             = 'CXMapKit'
    s.version          = '1.0'
    s.summary          = '地图SDK封装'
    
    # This description is used to generate tags and improve search results.
    # * Think: What does it do? Why did you write it? What is the focus?
    # * Try to keep it short, snappy and to the point.
    # * Write the description between the DESC delimiters below.
    # * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = '地图SDK封装'
    s.homepage         = 'https://github.com/ishaolin/CXMapKit'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'wshaolin' => 'ishaolin@163.com' }
    s.source           = { :git => 'https://github.com/ishaolin/CXMapKit.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '9.0'
    
    s.resource_bundles = {
      'CXMapKit' => ['CXMapKit/Assets/*']
    }
    
    s.public_header_files = 'CXMapKit/Classes/**/*.h'
    s.source_files = 'CXMapKit/Classes/**/*'
    
    # 新版本中 AMapNavi 中已包含 AMap3DMap 的内容
    # s.dependency 'AMap3DMap', '7.9.0'
    s.dependency 'AMapLocation', '2.6.8'
    s.dependency 'AMapSearch', '7.9.0'
    s.dependency 'AMapNavi', '7.9.0'
    s.dependency 'CXUIKit'
    s.dependency 'CXDatabaseSDK'
end
