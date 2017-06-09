class ShortUrl < ApplicationRecord
  require 'uri'
  include ShortUrlsHelper

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
  before_save :ensure_scheme

  ###### Public methods ########################

  # Sets up short URL slugs to be used as params in routing
  def to_param
    slug
  end
  
  class << self
    # Searches for short URL by slug
    def search(search)
      ShortUrl.where("slug ILIKE ?", "%#{search}%")
    end

    # Searches for short URLs by redirect
    def reverse_search(search)
      where("redirect ILIKE ?", "%#{search}%")
    end

    # Generates a random slug
    def random_slug(length = UrlGrey::Application.config.random_slug_length)
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
  def ensure_scheme
    self.redirect.insert(0, 'http://') unless URI.parse(self.redirect).scheme
  end
end
