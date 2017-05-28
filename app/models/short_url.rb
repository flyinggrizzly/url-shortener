class ShortUrl < ApplicationRecord
  require 'uri'

  ### ATTRIBUTES ###############################
  # UrlAlias model has the following attributes:
  # - (id:int)
  # - slug:string,   INDEXED
  # - redirect:text,      INDEXED
  # - created_at:datetime
  # - updated_at:datetime
  ##############################################


  # Validations
  validates :slug, presence:   true,
                   uniqueness: { case_sensitive: false },
                   length:     { maximum: 255 },
                   slug:       true

  validates :redirect,  presence: true,
                        length:   { maximum: 300 },
                        url:      true

  # Filters
  before_save :downcase_alias
  before_save :strip_scheme

  ###### Public methods ########################
  class << self
    def search(search)
      ShortUrl.where("slug ILIKE ?", "%#{search}%")
    end

    def reverse_search(search)
      where("redirect ILIKE ?", "%#{search}%")
    end
  end

  ###### Private methods #######################

  private

  ### Filters ###

  # Downcases a slug before saving
  def downcase_alias
    slug.downcase!
  end

  # Prepends the 'http://' scheme marker to redirects if they do not have it or 'https://'
  def strip_scheme
    if URI.parse(self.redirect).scheme
      redirect = self.redirect
      host = URI.parse(redirect).host
      self.redirect = redirect[redirect.index(host), redirect.size - 1]
    end
  end
end
