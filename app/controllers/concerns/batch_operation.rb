require 'active_support/concern'

module BatchOperation
  extend ActiveSupport::Concern

  require 'csv'

  # Renders form to upload many short URLs for update and creation via CSV
  def batch; end

  # Form for verifying multiple short URL creations and updates before submission
  def batch_edit_and_new
    short_urls = read_batch_csv
    @urls_to_update, @urls_to_create = identify_action_for_record(short_urls)
  end

  # Create and update short URLs in a batch
  def batch_update_and_create; end

  def edit
    @short_url = ShortUrl.find_by(slug: params[:slug])
  end

  private

  # Returns two arrays: one of short URLs to update, one of short URLs to create
  def identify_action_for_record(short_urls)
    short_urls.each do |short_url|
      if record = ShortUrl.find_by(slug: short_url[0])
        updates << [record: record, new_redirect: short_url[1]]
      else
        creates << short_url
      end
    end
    return updates, creates
  end

  # Reads and parses CSV for batch operation
  def read_batch_csv
    CSV.read(params[short_urls_csv_params])
  end

  # Accepts CSV files and sanitizes them for creating many short URLs
  def short_urls_csv_params
    params.require(:short_urls_csv).permit(:short_urls_csv)
  end
end