
require 'optparse'

options = {}
options[:newline] = true
OptionParser.new do |opt|
  opt.on('-e', '--emoji EMOJI', 'Sets the specified character as a favicon. (Not recommended, recommendation: specify character number with -u)') { |o| options[:emoji] = o }
  opt.on('-u', '--unicode UNICODE', 'E-mail address to be stored in the certificate.') { |o| options[:unicode] = o }
  opt.on('-c', '--no-newline', 'Specifies whether a new line should be created after the emoji. By default yes, by specifying this option no.') { options[:newline] = false }
  opt.on('-o', '--output FILE', 'The favicon.txt where the emoji should be stored.') { |o| options[:output] = o }
end.parse!

if options[:emoji] && options[:unicode]
  raise "You can specify either an emoji or a character number, not both."
end

unless options[:output]
  raise "You must specify a file in which the favicon will be saved. Normally this is the favicon.txt in the root directory of the site."
end

fil = File.new options[:output], "w"

if options[:emoji]
  fil.write options[:emoji]
elsif options[:unicode]
  fil.write options[:unicode].to_i(16).chr('UTF-8')
else
  raise "The favicon must be specified with a character or character number."
end

if options[:newline]
  fil.write "\r\n"
end
fil.close