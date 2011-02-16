require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'jido'

class Test::Unit::TestCase
end

class Hash
  def diff other
    self.keys.inject({}) do |memo, key|
      unless self[key] == other[key]
        memo[key] = [self[key], other[key]]
      end
      memo
    end
  end
end