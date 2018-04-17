require '/Users/gawain.reifsnyder/workspace/image-sizechecker/id.rb'

desc 'Check image sizes'
task :image_size_check do
  tester = JpegTester.new
  puts tester.stats
end
