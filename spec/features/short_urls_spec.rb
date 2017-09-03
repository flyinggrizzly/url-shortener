require 'rails_helper'
require 'csv'

RSpec.feature "ShortUrls", type: :feature do

  feature 'batch update and creation of short URLs' do
    around(:example) do |ex| # scenaria are examples
      @admin = FactoryGirl.create(:admin_user)
      CSV.read('spec/support/files/batch.csv').each do |slug, redirect|
        next if slug.include? 'new' || ShortUrl.find_by(slug: slug)
        FactoryGirl.create(:short_url, slug: slug, redirect: redirect)
      end

      ex.run

      @admin.destroy
      CSV.read('spec/support/files/batch.csv').each do |slug, redirect|
        next unless slug.include? 'new'
        if short_url = ShortUrl.find_by(slug: slug)
          short_url.destroy
        end
      end
    end

    # Returns hashes of the URLs to update and create defined in the CSV uploaded to the application
    def identify_urls_to_update_and_create(csv_name)
      updates, creates = {}, {}
      CSV.read(File.join('spec/support/files', csv_name)).each do |slug, redirect|
        updates[slug] = redirect if slug.include? 'pre-exist'
        creates[slug] = redirect if slug.include? 'new'
      end
      return updates, creates
    end

    def slugs_for_flash(short_url_hash)
      short_url_hash.keys.map { |slug| "'#{slug}'" }.join(', ')
    end

    scenario 'admin logs in and submits a valid batch', aggregate_failures: true, batch_test: true do
      csv_name = 'batch.csv'.freeze

      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(@admin)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      attach_file  'short_urls_csv', "spec/support/files/#{csv_name}"
      click_button 'Create short URLs'

      # track slugs being updated and created to test success in a minute
      updated_urls, created_urls = identify_urls_to_update_and_create(csv_name)

      # Expect each of the entries in the CSV to be present in the form
      updated_urls.each do |slug, redirect|
        within('fieldset#short-urls-to-update') do
          expect(page).to have_content(slug)
          expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
        end
      end
      created_urls.each do |slug, redirect|
        within('fieldset#short-urls-to-create') do
          expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
          expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
        end
      end

      click_button 'Submit short URLs for update and creation'
      
      expect(page).to have_content("Short URLs #{slugs_for_flash(updated_urls)} were updated. Short URLs #{slugs_for_flash(created_urls)} were created.")
    end

    scenario 'admin submits a batch with bad URLs to update', :aggregate_failures do
      csv_name = 'batch_with_bad_urls_to_update.csv'.freeze

      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(@admin)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      attach_file  'short_urls_csv', "spec/support/files/#{csv_name}"
      click_button 'Create short URLs'

      # track slugs being updated and created to test success in a minute
      updated_urls, created_urls = identify_urls_to_update_and_create(csv_name)

      # Expect each of the entries in the CSV to be present in the form
      updated_urls.each do |slug, redirect|
        within('fieldset#short-urls-to-update') do
          expect(page).to have_content(slug)
          expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
        end
      end
      created_urls.each do |slug, redirect|
        within('fieldset#short-urls-to-create') do
          expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
          expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
        end
      end

      click_button 'Submit short URLs for update and creation'

      # The URLs to be updated should still be in the form
      updated_urls.each do |slug, redirect|
        expect(page).to have_content(slug)
        expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
      end

      # Make sure that the URLs to be created happened
      expect(page).to have_content("Short URLs #{slugs_for_flash(created_urls)} were created.")

      # Make sure we're being told there were issues
      expect(page).to have_content("Some of your short URLs had problems. Please fix these. This has not prevented the valid ones from being updated or created.")
      expect(page).to have_css('.error_explanation ul li.error-item', count: 2)
    end

    scenario 'admin submits a batch with bad URLs to create', :aggregate_failures do
      csv_name = 'batch_with_bad_urls_to_create.csv'.freeze

      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(@admin)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      attach_file  'short_urls_csv', "spec/support/files/#{csv_name}"
      click_button 'Create short URLs'

      # track slugs being updated and created to test success in a minute
      updated_urls, created_urls = identify_urls_to_update_and_create(csv_name)

      # Expect each of the entries in the CSV to be present in the form
      updated_urls.each do |slug, redirect|
        within('fieldset#short-urls-to-update') do
          expect(page).to have_content(slug)
          expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
        end
      end
      created_urls.each do |slug, redirect|
        within('fieldset#short-urls-to-create') do
          expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
          expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
        end
      end

      click_button 'Submit short URLs for update and creation'

      # The URLs to be created should still be in the form
      created_urls.each do |slug, redirect|
        expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
        expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
      end

      # We should have confirmation that the updates worked
      expect(page).to have_content("Short URLs #{slugs_for_flash(updated_urls)} were updated.")

      # We should also be told that there were problems, but they didn't interfere with the successful operations
      expect(page).to have_content("Some of your short URLs had problems. Please fix these. This has not prevented the valid ones from being updated or created.")
      expect(page).to have_css('.error_explanation ul li.error-item', count: 2)
    end

    scenario 'admin submits a batch with all bad URLs', :aggregate_failures do
      csv_name = 'batch_all_bad.csv'.freeze

      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(@admin)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      attach_file  'short_urls_csv', "spec/support/files/#{csv_name}"
      click_button 'Create short URLs'
      save_page

      # track slugs being updated and created to test success in a minute
      updated_urls, created_urls = identify_urls_to_update_and_create(csv_name)

      # Expect each of the entries in the CSV to be present in the form
      updated_urls.each do |slug, redirect|
        within('fieldset#short-urls-to-update') do
          expect(page).to have_content(slug)
          expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
        end
      end
      created_urls.each do |slug, redirect|
        within('fieldset#short-urls-to-create') do
          expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
          expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
        end
      end

      click_button 'Submit short URLs for update and creation'

      updated_urls.each do |slug, redirect|
        expect(page).to have_content(slug)
        expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
      end
      created_urls.each do |slug, redirect|
        expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
        expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
      end

      expect(page).to have_content("Your short URLs had some problems. Please fix these.")
      expect(page).to have_css('.error_explanation ul li.error-item', count: 5) # the '  ' URL submitted triggers two errors: blankness, and URL validity
    end

    scenario 'admin tries to upload an empty file' do
      csv_name = 'batch_empty.csv'.freeze

      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(@admin)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      attach_file  'short_urls_csv', "spec/support/files/#{csv_name}"
      click_button 'Create short URLs'

      expect(page).to have_content('That CSV could not be read.')
    end

    scenario 'user tries to access the batch screen and is redirected to the short URLs index' do
      user = FactoryGirl.create(:user)
      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(user)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      expect(current_path).to eq(root_or_admin_path)
    end
  end
end
