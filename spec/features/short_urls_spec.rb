require 'rails_helper'
require 'csv'

RSpec.feature "ShortUrls", type: :feature do

  before(batch_test: true) do
    CSV.read('spec/support/files/batch.csv').each do |slug, redirect|
      next unless slug.include? 'pre-exists'
      FactoryGirl.create(:short_url, slug: slug, redirect: redirect)
    end
  end

  # after(batch_test: true) do
  #   CSV.read('spec/misc/batch.csv').each do |slug, redirect|
  #     next unless slug.include? 'new'
  #     short_url = ShortUrl.find_by(slug: slug)
  #     short_url.destroy
  #   end
  # end

  scenario 'user submits a valid batch of short URLs', aggregate_failures: true, batch_test: true do
    user = FactoryGirl.create(:admin_user) # batch operations are restricted to admins

    visit root_or_admin_path
    click_link   'Log in'
    fill_in      'Email',    with: user.email
    fill_in      'Password', with: user.password
    click_button 'Log in'

    click_link   'Create a Short URL'
    click_link   'Batch update and create'
    attach_file  'short_urls_csv', 'spec/support/files/batch.csv'
    click_button 'Create short URLs'

    # track slugs being updated and created to test success in a minute
    updated_slugs = []; created_slugs = []

    # Expect each of the entries in the CSV to be present in the form...
    CSV.read('spec/support/files/batch.csv').each do |slug, redirect|
      # ... those that need to be updated
      if slug.include? 'pre-exists'
        updated_slugs << "'#{slug}'"
        within('fieldset#short-urls-to-update') do
          expect(page).to have_content(slug)
          expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
        end
      # ... and the ones that need to be created.
      else
        created_slugs << "'#{slug}'"
        within('fieldset#short-urls-to-create') do
          expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
          expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
        end
      end
    end

    click_button 'Submit short URLs for update and creation'
    
    expect(page).to have_content("Short URLs #{updated_slugs.join(', ')} were updated. Short URLs #{created_slugs.join(', ')} were created.")
  end

  scenario 'user submits a batch of short URLs with bad URLs to create'
  scenario 'user submits a batch of short URLs with bad URLs to update'
end
