require 'active_support/concern'

module Batchable
  extend ActiveSupport::Concern

  require 'csv'

  # Renders form to upload many short URLs for update and creation via CSV
  def batch; end

  # Form for verifying multiple short URL creations and updates before submission
  def batch_edit_and_new
    if short_urls = read_batch_csv
      identify_action_for_record(short_urls)
    else
      # render a flash with problems
      render 'batch'
    end
  end

  # Create and update short URLs in a batch
  def batch_update_and_create
    short_urls_to_update = params[:short_urls_to_update]
    short_urls_to_create = params[:short_urls_to_create]

    # Clear the instance vars for the batch_edit-_and_new action in case we need to rerender
    # to deal with errors
    @updates = []
    @creates = []

    # Handle updates
    short_urls_to_update.keys.each do |key|
      short_url = ShortUrl.find_by(slug: key.to_s)
      short_urls_to_updateupdates << short_url unless short_url.update_attribute(:redirect, short_urls_to_update[key][:redirect])
    end

    # Handle creations
    short_urls_to_create.keys.each do |key|
      short_url = ShortUrl.new(slug: short_urls_to_create[key][:slug], redirect: short_urls_to_create[key][:redirect])
      @creates << short_url unless short_url.save
    end

    if @updates.empty? && @creates.empty?
      # TODO: flash listing successes
      redirect_to short_urls_path
    else
      render 'batch_edit_and_new'
    end
  end

  private

  # Returns two arrays: one of short URLs to update, one of short URLs to create
  def identify_action_for_record(short_urls)
    @updates = []
    @creates = []
    short_urls.each do |short_url|
      if record = ShortUrl.find_by(slug: short_url[:slug])
        record.redirect = short_url[:redirect] 
        @updates << record
      else
        @creates << ShortUrl.new(slug: short_url[:slug], redirect: short_url[:redirect])
      end
    end
  end

  # Reads and parses CSV for batch operation
  def read_batch_csv
    # TODO: error handling
    csv_lines = CSV.read(Rails.root.join('public', 'uploads', upload))

    short_urls = []
    csv_lines.each do |line|
      short_urls << {slug: line[0], redirect: line[1]}
    end
    return short_urls
  end

  # Accepts CSV files and sanitizes them for creating many short URLs
  def short_urls_csv_params
    params.require(:short_urls_csv)
  end

  def short_urls_batch_params
    params.require(:updates, :creates)
  end

  def upload
    uploaded_io = params[:short_urls_csv]
    File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
    uploaded_io.original_filename
  end
end
