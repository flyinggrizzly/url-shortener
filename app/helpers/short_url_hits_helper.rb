module ShortUrlHitsHelper
  # Records a Short URL's usage
  def record_hit(slug=nil)
    ip_address = request.ip
    user_agent = request.user_agent
    if slug
      short_url_id   = ShortUrl.find_by(slug: slug).id
      @short_url_hit = ShortUrlHit.new(short_url_id: short_url_id,
                                       ip_address:   ip_address,
                                       user_agent:   user_agent)
    else
      @short_url_hit = @short_url.hits.build(ip_address: ip_address,
                                             user_agent: user_agent)
    end
    @short_url_hit.save
  rescue
    return
  end
end