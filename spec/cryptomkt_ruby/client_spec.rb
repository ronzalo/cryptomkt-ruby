RSpec.describe CryptomktRuby::Client do
  it 'has a version number' do
    expect(CryptomktRuby::VERSION).not_to be nil
  end

  context 'signs message correctly' do
    subject { CryptomktRuby::Client.new('some_key', 'super_secure_secret') }

    expected_message = '883f32ab4cac82653fe16eb5febc494f4726e2d98df6a94b5a9cd2df493dc33889f4e4766f84e47c1e07a4d503847ea1'
    timestamp = '1356048000'
    path = '/api/coolEndpoint'

    it 'sort body attributes and concatenate correctly' do
      params = { market: 'ETCBTC', amount: '10', price: '1000', type: 'buy' }
      expect(
        subject.send(:signature, timestamp, path, params)
      ).to eq expected_message
    end

    it 'change signed message if body changes' do
      params = { market: 'ETCBTC', amount: '10', price: '1000', type: 'sell' }
      expect(
        subject.send(:signature, timestamp, path, params)
      ).not_to eq expected_message
    end

    it 'change signed message if client secret changes' do
      subject { CryptomktRuby::Client.new('some_key', 'another secret') }
      params = { market: 'ETCBTC', amount: '10', price: '1000', type: 'sell' }
      expect(
        subject.send(:signature, timestamp, path, params)
      ).not_to eq expected_message
    end
  end
end
