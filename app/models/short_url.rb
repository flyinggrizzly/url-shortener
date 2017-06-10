class ShortUrl < ApplicationRecord
  require 'uri'
  require 'radix'

  ### ATTRIBUTES ###############################
  # UrlAlias model has the following attributes:
  # - (id:int)
  # - slug:string,   INDEXED
  # - redirect:text,      INDEXED
  # - created_at:datetime
  # - updated_at:datetime
  ##############################################

  # Virtual attribute for random slug handling
  attr_accessor :random_slug

# Filters
  before_save :downcase_alias
  before_save :ensure_scheme

  before_validation :generate_random_slug


  # Validations
  validates :slug, presence:   true,
                   uniqueness: { case_sensitive: false },
                   length:     { maximum: 255 },
                   slug:       true

  validates :redirect,  presence: true,
                        length:   { maximum: 300 },
                        url:      true



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
      # If the app has a random current slug counter, use that
      if slug_id = AppConfig.current_random_slug
        # Generate the slug
        slug = base_37_convert(slug_id)
        AppConfig.current_random_slug += 1

        # Pad out shorter slugs to meet length param
        while slug.length < length
          slug.insert(0, '0')
        end

        # Make sure slug does not exist and doesn't include hyphens, or return it
        if slug.include?('-')
          random_slug(length)
        elsif ShortUrl.find_by(slug: slug)
          random_slug(length)
        else
          return slug
        end
      
      # Otherwise create the counter and recall the method
      else
        AppConfig.current_random_slug = 0
        random_slug(length)
      end
    end

    # Slug generator alphabet using the Radix gem
    def base_37_convert(number)
      base_37_alphabet = %w[0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z -]
      number.b(10).to_s(base_37_alphabet)
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

  # Creates a random slug if requested before validation
  def generate_random_slug
    if self.random_slug == '1' && self.slug.empty?
      self.slug = ShortUrl.random_slug
    end
  end
end
