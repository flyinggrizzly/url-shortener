require 'rails_helper'

RSpec.describe Batchable, type: :controller do

  # Declare an anonymous controller to test the concern on
  controller(ApplicationController) do
    include Batchable

    # Expose private methods for unit tests
    public :identify_action_for_record,
           :read_batch_csv,
           :short_urls_csv_params,
           :upload
  end

  before do
    routes.draw do
      get  'batch' => 'anonymous#batch'
      post 'batch' => 'anonymous#batch_edit_and_new'
    end
  end


  describe '#batch' do
    it 'responds successfully' do
      get :batch
      expect(response).to be_success
    end
  end

  describe '#batch_edit_and_new' do
    it 'responds successfully' do
      post :batch_edit_and_and_new
      expect(response).to be_success
    end
  end

  describe '#batch_update_and_create' do
  end

  describe '#identify_action_for_record(records)' do
  end

  describe '#read_batch_csv' do
  end

  describe '#short_urls_csv_params' do
    pending
  end

  describe '#short_urls_batch_params' do
    pending
  end

  describe '#upload' do

  end
end
