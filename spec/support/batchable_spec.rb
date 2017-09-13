shared_examples 'batch controller actions' do
  let(:controller) { create (described_class.to_s.underscore) }
  
  before(:example) do
    admin = FactoryGirl.create(:admin_user)
    log_in_as admin
  end

  describe '#batch' do
    it 'responds successfully' do
      get :batch
      expect(response).to be_success
    end
  end

  describe '#batch_edit_and_new' do
    it 'responds successfully'

    context 'when a valid CSV is uploaded' do
      it 'identifies the right short URLS to update'
      it 'identifies the right short URLs to create'
      it 'displays short URLs to update and create'
    end

    context 'when a bad CSV is uploaded' do
      it 'prompts for upload again'
      it 'gives a useful message about bad CSVs'
    end
  end

  describe '#batch_update_and_create' do
    context 'when there are no errors in the short URLs' do
      it 'lists the short URLs edited and created in the flash'
    end

    context 'when there are errors in the short URLs' do
      it 'modifies the @updates attribute with the short URLs that still need to be updated'
      it 'modifies the @creates attribute with the short URLs that still need to be created'
    end
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
    pending
  end
end