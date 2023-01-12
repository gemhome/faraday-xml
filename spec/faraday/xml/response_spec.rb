# frozen_string_literal: true

RSpec.describe Faraday::XML::Response, type: :response do
  let(:options) { {} }
  let(:headers) { {} }
  let(:middleware) do
    described_class.new(lambda { |env|
      Faraday::Response.new(env)
    }, **options)
  end
  let(:xml) do
    '<user><name>Erik Michaels-Ober</name><screen_name>sferik</screen_name></user>'
  end
  let(:parsed_xml) do
    { 'user' => { 'name' => 'Erik Michaels-Ober', 'screen_name' => 'sferik' } }
  end
  let(:invalid_xml) do
    '<xml'
  end

  def process(body, content_type = 'application/xml', options = {})
    env = {
      body: body, request: options,
      request_headers: Faraday::Utils::Headers.new,
      response_headers: Faraday::Utils::Headers.new(headers)
    }
    env[:response_headers]['content-type'] = content_type if content_type
    yield(env) if block_given?
    middleware.call(Faraday::Env.from(env))
  end

  context 'no type matching' do
    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it 'nullifies empty body' do
      expect(process('').body).to be_nil
    end

    it 'parses xml body' do
      response = process(xml)
      expect(response.body).to eq(parsed_xml)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context 'with preserving raw' do
    let(:options) { { preserve_raw: true } }

    it 'parses xml body' do
      response = process(xml)
      expect(response.body).to eq(parsed_xml)
      expect(response.env[:raw_body]).to eq(xml)
    end
  end

  context 'with default regexp type matching' do
    it 'parses xml body of correct type' do
      response = process(xml, 'text/xml; encoding="UTF-8";charset=UTF-8')
      expect(response.body).to eq(parsed_xml)
    end

    it 'ignores xml body of incorrect type' do
      response = process(xml, 'text/html')
      expect(response.body).to eq(xml)
    end
  end

  context 'with array type matching' do
    let(:options) { { content_type: %w[a/b c/d] } }

    it 'parses xml body of correct type' do
      expect(process(xml, 'a/b').body).to be_a(Hash)
      expect(process(xml, 'c/d').body).to be_a(Hash)
    end

    it 'ignores xml body of incorrect type' do
      expect(process(xml, 'a/d').body).not_to be_a(Hash)
    end
  end

  it 'chokes on invalid xml' do
    expect { process(invalid_xml) }.to raise_error(Faraday::ParsingError)
  end

  it 'includes the response on the ParsingError instance' do
    process(invalid_xml) { |env| env[:response] = Faraday::Response.new }
    raise 'Parsing should have failed.'
  rescue Faraday::ParsingError => e
    expect(e.response).to be_a(Faraday::Response)
  end

  context 'HEAD responses' do
    it "nullifies the body if it's only one space" do
      response = process(' ')
      expect(response.body).to be_nil
    end

    it "nullifies the body if it's two spaces" do
      response = process(' ')
      expect(response.body).to be_nil
    end
  end

  context 'XML options' do
    let(:body) { xml }
    let(:result) { parsed_xml }
    let(:options) do
      {
        parser_options: {
          disallowed_types: "yaml"
        }
      }
    end

    it 'passes relevant options to XML parse' do
      allow(middleware).to receive(:test_parser)
      expect(::Hash).to receive(:from_xml)
        .with(body, options.dig(:parser_options, :disallowed_types))
        .and_return(result)

      response = process(body)
      expect(response.body).to eq(result)
    end
  end
end
