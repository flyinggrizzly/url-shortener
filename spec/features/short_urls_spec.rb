require 'rails_helper'
require 'csv'

RSpec.feature "ShortUrls", type: :feature do

  before(batch_test: true) do
    CSV.read('spec/misc/batch.csv').each do |slug, redirect|
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

  scenario 'user creates short URLs in a batch', aggregate_failures: true, batch_test: true do
    user = FactoryGirl.create(:admin_user) # batch operations are restricted to admins

    visit root_or_admin_path
    click_link   'Log in'
    fill_in      'Email',    with: user.email
    fill_in      'Password', with: user.password
    click_button 'Log in'

    click_link   'Create a Short URL'
    click_link   'Batch update and create'
    attach_file  'short_urls_csv', 'spec/misc/batch.csv'
    click_button 'Create short URLs'

    # Expect each of the entries in the CSV to be present in the form...
    CSV.read('spec/misc/batch.csv').each do |slug, redirect|
      # ... those that need to be updated
      if slug.include? 'pre-exists'  
        within('fieldset#short-urls-to-update') do
          expect(page).to have_content(slug)
          expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
        end
      else
        # ... and the ones that need to be created.
        within('fieldset#short-urls-to-create') do
          expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
          expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
        end
      end
    end

    # Clear one of the inputs in each group to cause an error

    # Expect that some will have succeeded, the flash shows them

    # Expect that the ones we broke are still here to be created/updated and show relevant errors

    # Fix them, and resubmit; expect that we are redirected to '#index' and the flash shows the remaining ones
  end
end
