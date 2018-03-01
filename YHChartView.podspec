
Pod::Spec.new do |s|
  s.name         = "YHChartView"
  s.version      = "0.3.1"
  s.summary      = "Charts that support zoom, drag, and rotation, including vertical bar, horizontal bar, and line chart."
  s.description  = <<-DESC
***
## Features:
1. Support `ARC` & `Objective C`.
2. Powerful,support the  `bar chart` `line chart`.
3. Interactive、zoomable、dragable、rotatable.  
***
                   DESC

  s.homepage     = "https://github.com/whoyoung/YHChartView"
  s.license      = "MIT"

  s.author             = { "杨虎" => "huyang@mail.bistu.edu.cn" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/whoyoung/YHChartView", :tag => "#{s.version}" }

  s.source_files  = "YHChartView/*.{h,m}"
  s.requires_arc = true

end
