Pod::Spec.new do |s|
  s.name             = "FlexibleTableView"
  s.version          = "1.0.0"
  s.summary          = "A flexible tableview used on iOS implement by swift."
  s.homepage         = "https://github.com/FlexibleTableView/FlexibleTableView"
  s.license          = 'MIT'
  s.author           = { "吴浩文" => "alex.haowen.wu@gmail.com" }
  s.source           = { :git => "https://github.com/FlexibleTableView/FlexibleTableView.git", :tag => s.version }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Source/*'
end