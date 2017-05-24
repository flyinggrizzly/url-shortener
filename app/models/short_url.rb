class ShortUrl < ApplicationRecord
  require 'uri'

  ### ATTRIBUTES ###############################
  # UrlAlias model has the following attributes:
  # - (id:int)
  # - url_alias:string,   INDEXED
  # - redirect:text,      INDEXED
  # - user_id,            INDEXED, reference to user table
  # - created_at:datetime
  # - updated_at:datetime
  ##############################################

  # Filters
  before_save       :downcase_alias
  before_validation :prepend_http_scheme_to_redirect

  # Validations
  validates :url_alias, presence: true,
                        uniqueness: { case_sensitive: false },
                        length: { maximum: 255 }

  validates :redirect,  presence: true, 
                        format: URI.regexp(['http', 'https']),
                        length: { maximum: 300 }
  validates :user_id,   presence: true

  belongs_to :user
  ###### Public methods ###############################################################################################


  ###### Private methods ##############################################################################################

  private

  ### Filters ###

  # Downcases a url_alias before saving
  def downcase_alias
    url_alias.downcase!
  end

  # Prepends the 'http://' scheme marker to redirects if they do not have it or 'https://'
  def prepend_http_scheme_to_redirect
    unless self.redirect.blank?
      redirect = self.redirect.insert(0, 'http://') unless self.redirect.start_with?('http://', 'https://')
    end
  end
end
