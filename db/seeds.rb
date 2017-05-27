User.create!(name:                  'Great Cthulhu',
             email:                 'og_old_one@lovecraft.net',
             admin:                 true,
             password:              'goofballgoofball',
             password_confirmation: 'goofballgoofball')

User.create!(name:                  'Yig',
             email:                 'snaketongue@lovecraft.net',
             admin:                 false,
             password:              'goofballgoofball',
             password_confirmation: 'goofballgoofball')

User.create!(name:                  'Hastur',
             email:                 'hasturhasturhastur@lovecraft.net',
             admin:                 false,
             password:              'goofballgoofball',
             password_confirmation: 'goofballgoofball')

52.times do |n|
  u_name   = Faker::Name.name
  email    = "cultist-#{n+1}@weworshipgreatcthul.hu"
  password = 'goofballgoofball'
  User.create!(name:                  u_name,
               email:                 email,
               admin:                 false,
               password:              password,
               password_confirmation: password)
end

50.times do |n|
  u_alias  = "foo#{n}"
  redirect = 'https://www.google.com'
  ShortUrl.create!(slug: u_alias,
                   redirect:  redirect)
end
