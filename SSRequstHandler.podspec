Pod::Spec.new do |s|
  s.name         = "SSRequstHandler"
  s.version      = "0.0.1"
  s.summary      = "A short description of SSRequstHandler."
  s.description  = <<-DESC
                    Hi, SSRequstHandler!
                   DESC
  s.homepage     = "git@gitee.com:xiazer/SSRequstHandler.git"
  s.license      = "MIT"
  s.author       = { "Summer Solstice" => "kingundertree@163.com" }
  s.platform     = :ios, "9.0"
#  s.source       = { :git => "git@gitee.com:xiazer/SSRequstHandler.git", :tag => "#{s.version}" }
s.source           = { :git => '', :tag => s.version.to_s }

  s.source_files        = 'Sources/*.h'
  s.public_header_files = 'Sources/*.h'
#  s.static_framework = true
#  s.ios.resources = ["Resources/**/*.{png,json}","Resources/*.{html,png,json}", "Resources/*.{xcassets, json}", "Sources/**/*.xib"]

  s.subspec 'Category' do |ss|
    ss.source_files = 'Sources/Category/*.{h,m,swift}'
    ss.public_header_files = 'Sources/Category/*.h'
  end

  s.subspec 'SSBaseApi' do |ss|
      ss.source_files = 'Sources/SSBaseApi/*.{h,m,swift}'
      ss.public_header_files = 'Sources/SSBaseApi/*.h'
  end

  s.subspec 'SSRequestPlugin' do |ss|
      ss.source_files = 'Sources/SSRequestPlugin/*.{h,m,swift}'
      ss.public_header_files = 'Sources/SSRequestPlugin/*.h'
  end

  s.subspec 'SSRequestProtocol' do |ss|
      ss.source_files = 'Sources/SSRequestProtocol/*.{h,m,swift}'
      ss.public_header_files = 'SSRequestProtocol/Log/*.h'
  end

  s.subspec 'SSResponse' do |ss|
      ss.source_files = 'Sources/SSResponse/*.{h,m,swift}'
      ss.public_header_files = 'Sources/SSResponse/*.h'
  end

  s.subspec 'SSRequestError' do |ss|
      ss.source_files = 'Sources/SSRequestError/*.{h,m,swift}'
      ss.public_header_files = 'Sources/SSRequestError/*.h'
  end

  s.subspec 'SSRequestHandler' do |ss|
      ss.source_files = 'Sources/SSRequestHandler/*.{h,m,swift}'
      ss.public_header_files = 'Sources/SSRequestHandler/*.h'
  end

  s.subspec 'Others' do |ss|
      ss.source_files = 'Sources/Others/*.{c,h,m,swift}'
      ss.public_header_files = 'Sources/Others/*.h'
  end

  s.subspec 'SSRequestSetting' do |ss|
      ss.source_files = 'Sources/SSRequestSetting/*.{c,h,m,swift}'
      ss.public_header_files = 'Sources/SSRequestSetting/*.h'
  end

  s.subspec 'SSRequestDebugLog' do |ss|
      ss.source_files = 'Sources/SSRequestDebugLog/*.{c,h,m,swift}'
      ss.public_header_files = 'Sources/SSRequestDebugLog/*.h'
  end
  
  s.dependency 'AFNetworking'
  s.dependency 'SwiftyJSON'
  
end
