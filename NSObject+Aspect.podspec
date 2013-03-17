Pod::Spec.new do |s|
  s.name         = "NSObject+Aspect"
  s.version      = "0.0.2"
  s.summary      = "NSObject+Aspect is a category of aspect oriented programming for NSObject of Objective-C."
  s.homepage     = "https://github.com/rizumita/NSObject-Aspect"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Ryoichi Izumita" => "r.izumita@caph.jp" }
  s.source       = { :git => "https://github.com/rizumita/NSObject-Aspect.git", :tag => "0.0.2" }
  s.source_files = 'NSObject+Aspect/NSObject+Aspect.{h,m}'
  s.requires_arc = true
end
