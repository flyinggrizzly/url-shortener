require 'active_support/concern'

module Batchable
  extend ActiveSupport::Concern

  require 'csv'

  # Renders form to upload many short URLs for update and creation via CSV
  def batch; end

  # Form for verifying multiple short URL creations and updates before submission
  def batch_edit_and_new
    if short_urls = read_batch_csv
      @updates, @creates = identify_action_for_record(short_urls)
    else
      # render a flash with problems
      render 'batch'
    end
  end

  # Create and update short URLs in a batch
  def batch_update_and_create
    # Clear the instance vars for the batch_edit-_and_new action in case we need to rerender
    # to deal with errors
    @updates = []; @creates = []

    # Arrays to record the slugs of short URLs updated and created for the flash
    updated_slugs_to_flash = []; created_slugs_to_flash = []

    short_urls_to_update = params[:short_urls_to_update]
    short_urls_to_create = params[:short_urls_to_create]

    if short_urls_to_update.empty? && short_urls_to_create.empty?
      flash[:danger] = 'Could not read CSV.'
      render 'batch'
    else
      # Handle updates
      if short_urls_to_update
        # @updates = ShortUrl.batch_update_redirects(short_urls_to_update.values)
        short_urls_to_update.values.each do |attributes|
          # attributes = short_urls_to_update[key]
          short_url = ShortUrl.find_by(slug: attributes[:slug])
          short_url.redirect = attributes[:redirect]
          if short_url.save
            # We need to flash this one succeeded
            updated_slugs_to_flash << attributes[:slug]
          else
            # or we need to save it for the user to try again after fixing it
            @updates << short_url 
          end
        end
      end

      # Handle creations
      if short_urls_to_create
        # @creates = ShortUrl.batch_create(short_urls_to_create.values)
        short_urls_to_create.values.each do |attributes|
          # attributes = short_urls_to_create[key]
          short_url = ShortUrl.new(slug: attributes[:slug], redirect: attributes[:redirect])
          if short_url.save
            # We need to flash this one succeeded
            created_slugs_to_flash << attributes[:slug]
          else
            # or we need to save it for the user to try again after fixing it
            @creates << short_url
          end
        end
      end
    end

    # Set up the flash
    if @updates.empty? && @creates.empty?
      # If we have no more short URLs to work with, everything was a success
      batch_operation_flash(updated_slugs_to_flash, created_slugs_to_flash)
      redirect_to short_urls_path
    else 
      # Otherwise, we still have some short URLs that failed validation to update or create
      # Let the user know which short URLs, if any, succeeded
      batch_operation_flash(updated_slugs_to_flash, created_slugs_to_flash)

      # They had no short URLs succeed
      if flash[:success].blank?
        flash[:warn] = "Your short URLs had some problems. Please fix these."
      # Some short URLs succeeded, but there were some problems with others
      else
        flash[:warn] = "Some of your short URLs had problems. Please fix these. This has not prevented the valid ones from being updated or created."
      end
      render 'batch_edit_and_new'
    end
  end

  private

  # Returns two arrays: one of short URLs to update, one of short URLs to create
  def identify_action_for_record(short_urls)
    updates = []; creates = []
    short_urls.each do |short_url|
      if record = ShortUrl.find_by(slug: short_url[:slug])
        record.redirect = short_url[:redirect] 
        updates << record
      else
        creates << ShortUrl.new(slug: short_url[:slug], redirect: short_url[:redirect])
      end
    end
    return updates, creates
  end

  # Reads and parses CSV for batch operation
  def read_batch_csv
    # TODO: error handling
    csv_lines = CSV.read(Rails.root.join('public', 'uploads', upload))

    short_urls = []
    csv_lines.each do |line|
      short_urls << {slug: line[0], redirect: line[1]}
    end
    delete_csv(upload)
    return short_urls
  end

  # Deletes CSV upload
  def delete_csv(filename)
    File.delete(File.join('public', 'uploads', filename))
  end

  # Accepts CSV files and sanitizes them for creating many short URLs
  def short_urls_csv_params
    params.require(:short_urls_csv)
  end

  def upload
    uploaded_io = short_urls_csv_params
    File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
    uploaded_io.original_filename
  end

  def batch_operation_flash(updated_slugs, created_slugs)
    flash_updated = String.new; flash_created = String.new
    unless updated_slugs.empty?
      updated_slugs_string = updated_slugs.join("', '").insert(0, "'").insert(-1, "'")
      flash_updated = "Short #{'URL'.pluralize(updated_slugs.size)} #{updated_slugs_string} #{'was'.pluralize(updated_slugs.size)} updated."
    end
    unless created_slugs.empty?
      created_slugs_string = created_slugs.join("', '").insert(0, "'").insert(-1, "'")
      flash_created = "Short #{'URL'.pluralize(created_slugs.size)} #{created_slugs_string} #{'was'.pluralize(created_slugs.size)} created."
    end

    if updated_slugs.empty? && created_slugs.empty?
      flash.delete(:success)
    else
      flash[:success] = [flash_updated, flash_created].reject(&:blank?).join(' ')
    end
  end
end
