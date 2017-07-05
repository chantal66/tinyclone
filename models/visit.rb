class Visit < ActiveRecord::Base

  include DataMapper::Resource

  property  :id,          Serial
  property  :created_at,  DateTime
  property  :ip,          IPAddress
  property  :country,     String
  belongs_to  :link

  after :create, :set_country

  def set_country
    xml = RestClient.get "http://api.hotip.info/get_xml.php?ip=#{ip}"
    self.country = XmlSimple.xml_in(xml.to_s, {'ForceArray' => false})['featureMember']['Hostip']['CountryAbbrev']
    self.save
  end

  def self.count_by_date_with(identifier, num_of_days)
    visits = repository(:default.adapter.query("SELECT date(created_at) as date, count(*) as count FROM visits where
                                                link_identifier = #{identifier} and created_at between
                                                CURRENT_DATE-#{num_of_days} and CURRENT_DATE+1 group by date(created_at)"))
    dates = (Date.today-num_of_days..Date.today)
    results = {}
    dates.each { |date|
      visits.each { |visit| results[date] = visit.count if visit.date == date }
      results[date] = 0 unless results[date]
    }
    results.sort.reverse
  end

  def self.count_by_country_with(identifier)
    repository(:default).adapter.query("SELECT country, count(*) as count FROM visits WHERE link_identifier =
                                       #{identifier} group by country")
  end

  def self.count_days_bar(identifier,num_of_days)
    visits = count_by_date_with(identifier,num_of_days)
    data, labels = [], []
    visits.each {|visit| data << visit[1]; labels << "#{visit[0].day}/#{visit[0].month}" }
    "http://chart.apis.google.com/chart?chs=820x180&cht=bvs&chxt=x&chco=a4b3f4&chm=N,000000,0,-1,11&chxl=0:|
     #{labels.join('|')}&chds=0,#{data.sort.last+10}&chd=t:#{data.join(',')}"
  end

  def self.count_country_chart(identifier,map)
    countries, count = [], []
    count_by_country_with(identifier).each {|visit| countries << visit.country; count << visit.count }
    chart = {}
    chart[:map] = "http://chart.apis.google.com/chart?chs=440x220&cht=t&chtm=#{map}&chco=FFFFFF,a4b3f4,
                   0000FF&chld=#{countries.join('')}&chd=t:#{count.join(',')}"
    chart[:bar] = "http://chart.apis.google.com/chart?chs=320x240&cht=bhs&chco=a4b3f4&chm=N,000000,0,-1,11&chbh=a&chd=t:
                  #{count.join(',')}&chxt=x,y&chxl=1:|#{countries.reverse.join('|')}"
    return chart
  end
end