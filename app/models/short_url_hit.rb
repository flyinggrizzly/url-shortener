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

end
