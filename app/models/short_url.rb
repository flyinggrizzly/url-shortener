class ShortUrl < ApplicationRecord
  require 'uri'

  ### ATTRIBUTES ###############################
  # UrlAlias model has the following attributes:
  # - (id:int)
  # - url_alias:string,   INDEXED
  # - redirect:text,      INDEXED
  # - created_at:datetime
  # - updated_at:datetime
  ##############################################


  # Validations
  validates :url_alias, presence: true,
                        uniqueness: { case_sensitive: false },
                        length: { maximum: 255 }

  validates :redirect,  presence: true,
                        length:   { maximum: 300 }

  validates :redirect, url: true

  # Filters
  before_save :downcase_alias

  ###### Public methods ########################


  ###### Private methods #######################

  private

  ### Filters ###

  # Downcases a url_alias before saving
  def downcase_alias
    url_alias.downcase!
  end

  # Prepends the 'http://' scheme marker to redirects if they do not have it or 'https://'
end
