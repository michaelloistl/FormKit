Pod::Spec.new do |s|
    s.name = 'FormKit'
    s.version = '0.2.0'
    s.license = 'MIT'
    s.summary = 'Forms in Swift'
    s.authors = { 'Michael Loistl' => 'michael@aplo.co' }
    s.homepage = "https://github.com/michaelloistl/FormKit"
    s.source = { :git => 'https://github.com/michaelloistl/FormKit.git', :tag => s.version }

    s.ios.deployment_target = '8.0'
    s.osx.deployment_target = '10.9'
    s.watchos.deployment_target = '2.0'

    s.source_files = 'FormKit/*.{swift}'

    s.requires_arc = true

    s.dependency 'PureLayout', '~> 3.0'
    s.dependency 'RealmSwift', '~> 1.0'
end
