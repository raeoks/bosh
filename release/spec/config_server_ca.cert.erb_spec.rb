require 'rspec'
require 'bosh/template/evaluation_context'

describe 'director.yml.erb.erb' do
  let(:deployment_manifest_fragment) do
    {
      'properties' => {
        'director' => {
          'config_server' => {
            'enabled' => true
          }
        }
      }
    }
  end

  let(:erb_yaml) { File.read(File.join(File.dirname(__FILE__), '../jobs/director/templates/config_server_ca.cert.erb')) }

  subject(:parsed_erb) do
    binding = Bosh::Template::EvaluationContext.new(deployment_manifest_fragment).get_binding
    ERB.new(erb_yaml).result(binding)
  end

  it 'raises an error when config server is enabled but no certificate is defined' do
    expect { parsed_erb }.to raise_error(Bosh::Template::UnknownProperty)
  end

  context 'when all needed properties exist and it is enabled' do
    before do
      deployment_manifest_fragment['properties']['director']['config_server']['ca_cert'] = 'certs-r-us'
    end

    it 'renders the ca cert correctly' do
      expect(parsed_erb).to eq('certs-r-us')
    end

    context 'when the certificate has no new lines' do
      before do
        deployment_manifest_fragment['properties']['director']['config_server']['ca_cert'] = "certs-r-us\\nsecond line"
      end

      it 'substitutes escaped new lines with newlines characters and renders the ca cert correctly' do
        expect(parsed_erb).to eq("certs-r-us\nsecond line")
      end
    end
  end

  context 'when config server is not enabled' do
    before do
      deployment_manifest_fragment['properties']['director']['config_server']['enabled'] = false
    end

    it 'renders the ca cert to empty string' do
      expect(parsed_erb).to eq('')
    end
  end
end
