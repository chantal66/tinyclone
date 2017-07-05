class Url
  include DataMapper::Resource
  property  :id,          Serial
  property  :original,    String, :length => 255
  belongs_to  :link
end