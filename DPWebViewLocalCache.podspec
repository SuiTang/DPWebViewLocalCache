Pod::Spec.new do |s|

s.name         = "DPWebViewLocalCache"
s.version      = "1.1.0"
s.ios.deployment_target = '7.0'
s.summary      = "A delightful setting interface framework."
s.homepage     = "https://github.com/xiayuqingfeng/DPWebViewLocalCache"
s.license              = { :type => "MIT", :file => "LICENSE" }
s.author             = { "涂鸦" => "13673677305@163.com" }
s.source       = { :git => "https://github.com/xiayuqingfeng/DPWebViewLocalCache.git", :tag => s.version }
s.source_files  = "DPWebViewLocalCache_SDK/**/*.{h,m}"
s.requires_arc = true
end
