class Link < ActiveRecord::Base
  include DataMapper::Resource
  property  :identifier,  String, :key => true
  property  :created_at,  DateTime
  has 1, :url
  has n, :visits

  def self.shorten(original, custom = nil)
    url = Url.first(:original => original)
    return url.link if url
    link  = nil
    if custom
      raise 'Someone has already taken this custom URL, SORRY 😭' unless Link.first(:identifier => custom).nil?

      raise 'This custom URL is not allowed because of profanity' if DIRTY_WORDS.include? custom
      transaction do |txn|
        link = Link.new(:identifier => custom)
        link.url = Url.create(:original => original)
        link.save
      end
    else
      transaction do |txn|
        link = create_link(original)
      end
    end
    return link
  end

  private

  def self.create_link(original)
    url = Url.create(:original => original)
    if Link.first(:identifier => url.id.to_s(36)).nil? or !DIRTY_WORDS.include? url.id.to_s(36)
      link = Link.new(:identifier => url.id.to_s(36))
      link.url = url
      link.save
      return link
    else
      create_link(original)
    end
  end
end