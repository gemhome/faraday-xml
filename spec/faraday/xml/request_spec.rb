# frozen_string_literal: true

RSpec.describe Faraday::XML::Request, type: :request do
  let(:middleware) do
    described_class.new(lambda { |env|
      Faraday::Response.new(env)
    }, encoder_options: {
      indent: 0
    })
  end
  let(:xml) do
    '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>'
  end
  let(:input_hash) do
    { 'user' => { 'name' => 'Erik Michaels-Ober', 'screen_name' => 'sferik' } }
  end
  let(:invalid_xml) do
    '<xml'
  end

  def process(body, content_type = nil)
    env = { body: body, request_headers: Faraday::Utils::Headers.new }
    env[:request_headers]['content-type'] = content_type if content_type
    middleware.call(Faraday::Env.from(env)).env
  end

  def result_body
    result[:body]
  end

  def result_type
    result[:request_headers]['content-type']
  end

  context 'with no body' do
    let(:result) { process(nil) }

    it "doesn't change body" do
      expect(result_body).to be_nil
    end

    it "doesn't add content type" do
      expect(result_type).to be_nil
    end
  end

  context 'with empty body' do
    let(:result) { process('') }

    it "doesn't change body" do
      expect(result_body).to be_empty
    end

    it "doesn't add content type" do
      expect(result_type).to be_nil
    end
  end

  context 'with string body' do
    let(:result) { process(xml) }

    it "doesn't change body" do
      expect(result_body).to eq(xml)
    end

    it 'adds content type' do
      expect(result_type).to eq('application/xml')
    end
  end

  context 'with object body' do
    let(:result) { process(input_hash) }

    it 'encodes body' do
      expect(result_body).to eq(xml)
    end

    it 'adds content type' do
      expect(result_type).to eq('application/xml')
    end
  end

  context 'with empty object body' do
    let(:result) { process({}) }

    it 'encodes body' do
      expect(result_body).to eq('')
    end
  end

  context 'with object body with xml type' do
    let(:result) { process(input_hash, 'application/xml; charset=utf-8') }

    it 'encodes body' do
      expect(result_body).to eq(xml)
    end

    it "doesn't change content type" do
      expect(result_type).to eq('application/xml; charset=utf-8')
    end
  end

  context 'with object body with vendor xml type' do
    let(:result) { process(input_hash, 'application/vnd.myapp.v1+xml; charset=utf-8') }

    it 'encodes body' do
      expect(result_body).to eq(xml)
    end

    it "doesn't change content type" do
      expect(result_type).to eq('application/vnd.myapp.v1+xml; charset=utf-8')
    end
  end

  context 'with object body with incompatible type' do
    let(:result) { process(input_hash, 'application/json; charset=utf-8') }

    it "doesn't change body" do
      expect(result_body).to eq(input_hash)
    end

    it "doesn't change content type" do
      expect(result_type).to eq('application/json; charset=utf-8')
    end
  end
end
