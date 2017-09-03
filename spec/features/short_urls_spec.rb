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
      CSV_NAME = 'batch.csv'.freeze

      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(@admin)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      attach_file  'short_urls_csv', "spec/support/files/#{CSV_NAME}"
      click_button 'Create short URLs'

      # track slugs being updated and created to test success in a minute
      updated_urls, created_urls = identify_urls_to_update_and_create(CSV_NAME)

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
      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(@admin)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      attach_file  'short_urls_csv', 'spec/support/files/batch_with_bad_urls_to_update.csv'
      click_button 'Create short URLs'

      # track slugs being updated and created to test success in a minute
      updated_slugs = []; created_slugs = []

      # Expect each of the entries in the CSV to be present in the form...
      CSV.read('spec/support/files/batch_with_bad_urls_to_update.csv').each do |slug, redirect|
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

      CSV.read('spec/support/files/batch_with_bad_urls_to_update.csv').each do |slug, redirect|
        next unless slug.include? 'pre-exist'
        expect(page).to have_content(slug)
        expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
      end

      expect(page).to have_content("Short URLs #{created_slugs.join(', ')} were created.")
      expect(page).to have_content("Some of your short URLs had problems. Please fix these. This has not prevented the valid ones from being updated or created.")
      expect(page).to have_css('.error_explanation ul li.error-item', count: 2)
    end

    scenario 'admin submits a batch with bad URLs to create', :aggregate_failures do
      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(@admin)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      attach_file  'short_urls_csv', 'spec/support/files/batch_with_bad_urls_to_create.csv'
      click_button 'Create short URLs'

      # track slugs being updated and created to test success in a minute
      updated_slugs = []; created_slugs = []

      # Expect each of the entries in the CSV to be present in the form...
      CSV.read('spec/support/files/batch_with_bad_urls_to_create.csv').each do |slug, redirect|
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

      CSV.read('spec/support/files/batch_with_bad_urls_to_create.csv').each do |slug, redirect|
        next unless slug.include? 'new'
        expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
        expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
      end

      expect(page).to have_content("Short URLs #{updated_slugs.join(', ')} were updated.")
      expect(page).to have_content("Some of your short URLs had problems. Please fix these. This has not prevented the valid ones from being updated or created.")
      expect(page).to have_css('.error_explanation ul li.error-item', count: 2)
    end

    scenario 'admin submits a batch with all bad URLs', :aggregate_failures do
      visit root_or_admin_path
      click_link   'Log in'
      fill_in_login_details_and_log_in_as(@admin)

      click_link   'Create a Short URL'
      click_link   'Batch update and create'
      attach_file  'short_urls_csv', 'spec/support/files/batch_all_bad.csv'
      click_button 'Create short URLs'

      # track slugs being updated and created to test success in a minute
      updated_slugs = []; created_slugs = []

      # Expect each of the entries in the CSV to be present in the form...
      CSV.read('spec/support/files/batch_all_bad.csv').each do |slug, redirect|
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

      CSV.read('spec/support/files/batch_all_bad.csv').each do |slug, redirect|
        if slug.include? 'new'
          expect(page).to have_field("short_urls_to_create[#{slug}][slug]", with: slug)
          expect(page).to have_field("short_urls_to_create[#{slug}][redirect]", with: redirect)
        else
          expect(page).to have_content(slug)
          expect(page).to have_field("short_urls_to_update[#{slug}][redirect]", with: redirect)
        end
      end

      expect(page).to have_content("Your short URLs had some problems. Please fix these.")
      expect(page).to have_css('.error_explanation ul li.error-item', count: 5) # the '  ' URL submitted triggers two errors: blankness, and URL validity
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
