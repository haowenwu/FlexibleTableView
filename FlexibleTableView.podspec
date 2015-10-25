Pod::Spec.new do |s|
  s.name             = "FlexibleTableView"
  s.version          = "1.1.1"
  s.summary          = "A flexible tableview used on iOS implement by swift."
  s.homepage         = "https://github.com/awuu/FlexibleTableView"
  s.license          = 'MIT'
  s.author           = { "吴浩文" => "alexwuhw@gmail.com" }
  s.source           = { :git => "https://github.com/awuu/FlexibleTableView.git", :tag => s.version }

  s.platform         = :ios, '8.0'
  s.requires_arc     = true

  s.source_files     = 'Source/*'
end