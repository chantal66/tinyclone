DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://root:root@localhost/tiny_clone_app')
class Url
  include DataMapper::Resource
  property  :id,          Serial
  property  :original,    String, :length => 255
  belongs_to  :link
end