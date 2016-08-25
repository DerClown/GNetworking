Pod::Spec.new do |s|

  s.name         = "GNetworking"
  
  s.version      = "1.0"
  
  s.summary      = "A high level request engine based on AFNetworking."
  s.homepage     = "https://github.com/DongZai/GNetworking"
  s.license      = "MIT"
   
  s.author       = { "Dongzai" => "839235027@qq.com" }
  s.source       = { :git => "https://github.com/DongZai/GNetworking.git”, :tag => s.version.to_s }
  s.source_files  = "GNetworking/*.{h,m}"
  s.platform      = :ios, '6.0'
  s.requires_arc  = true
  s.dependency "AFNetworking", "~> 2.6.3"
  s.dependency "AFDownloadRequestOperation", "~> 2.0.1"

end
