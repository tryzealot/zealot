require 'benchmark'

Benchmark.bm(10) do |x|
  x.report("htp:") { 
    require 'http'
    100.times do |i|
      res = Http.get('http://localhost:3000/api/v2/apps')
    end
  }
end