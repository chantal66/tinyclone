%w(sinatra ./tinyclone).each  { |lib| require lib}
require 'rubygems'
require './tinyclone'
run Sinatra::Application