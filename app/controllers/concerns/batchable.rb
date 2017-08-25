require 'active_support/concern'

module Batchable
  extend ActiveSupport::Concern

  require 'csv'

  # Renders form to upload many short URLs for update and creation via CSV
  def batch; end

  # Form for verifying multiple short URL creations and updates before submission
  def batch_edit_and_new
    if @short_urls = read_batch_csv
      identify_action_for_record(@short_urls)
    else
      # render a flash with problems
      render 'batch'
    end
  end

  # Create and update short URLs in a batch
  def batch_update_and_create
  end

  private

  # Returns two arrays: one of short URLs to update, one of short URLs to create
  def identify_action_for_record(short_urls)
    @updates = []
    @creates = []
    @short_urls.each do |short_url|
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

  def upload
    uploaded_io = params[:short_urls_csv]
    File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
    uploaded_io.original_filename
  end
end
