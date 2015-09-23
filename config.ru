# Process.setrlimit(Process::RLIMIT_NOFILE, 4096, 65536)
require File.join(File.dirname(__FILE__), "app")

use Rack::CommonLogger
use Rack::ContentLength
use Rack::ContentType, 'text/html; charset=utf-8'

map '/assets' do
  run Rack::Directory.new('public')
end

map '/comet' do
  use Comet::Trapper
  run Comet::App.new
end

map '/' do
  run IRC_Log::App.new
end
