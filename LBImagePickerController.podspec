Pod::Spec.new do |s|
  s.name                  = 'LBImagePickerController'
  s.version               = '1.0.0'
  s.summary               = 'A clone of the UIImagePickerController using the Assets Library Framework allowing for multiple asset selection'
  s.homepage              = 'https://github.com/ocarol/LBImagePickerController'
  s.license               = { :type => 'MIT', :file => 'README.md' }
  s.author                = { 'ocarol' => 'yulili2020@qq.com' }
  s.source                = { :git => 'https://github.com/ocarol/LBImagePickerController.git', :tag => "#{s.version}" }
  s.platform              = :ios
  s.ios.deployment_target = "6.0"
  s.requires_arc          = true
  s.source_files          = 'LBImagePickerController/*.{h,m}'
  s.resources             = 'LBImagePickerController/*.{png,xib,nib,bundle}'
end