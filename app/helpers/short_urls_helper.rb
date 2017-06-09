module ShortUrlsHelper
  require 'radix'

  # Slug generator alphabet
  def base_37_convert(number)
    base_37_alphabet = %w(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z -)
    number.b(10).to_s(base_37_alphabet)
  end
end
