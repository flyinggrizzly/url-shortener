class ShortUrlHit < ApplicationRecord

  belongs_to :short_url

  ### ATTRIBUTES ###############################
  # ShortUrlHit model has the following attributes:
  # - (id:int)
  # - short_url:references, INDEXED
  # - ip_address:string
  # - user_agent:string
  # - created_at:date_time
  # - updated_at:date_time
  ##############################################

  validates :short_url_id, presence:          true

  class << self
    def count_last_30_days
      count_in_period(29.days.ago, Time.now)
    end
  end

  private
  
  class << self
    def count_in_period(begin_date, end_date)
      ShortUrlHit.where('created_at BETWEEN ? AND ?', begin_date.beginning_of_day, end_date.end_of_day).count
    end
  end

end
