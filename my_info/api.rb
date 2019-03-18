require 'http'
require 'jwe'

module MyInfo
  class Api
    # endpoint method name
    ENDPOINT = {
      person_basic: 'person-basic',
      authorise: 'authorise',
      token: 'token',
      person: 'person'
    }.freeze

    attr_accessor :realm, :app_id, :client_id, :singpass_eservice_id, :mode, :private_key, :base_url,
                  :timestamp, :nonce, :response

    # initialize MyInfo Api with realm, app_id, singpass_eservice_id, private_key
    # myinfo_config is a Hash{}
    def initialize(myinfo_config)
      @realm = myinfo_config[:realm]
      @app_id = myinfo_config[:app_id]
      @client_id = myinfo_config[:client_id] || myinfo_config[:app_id]
      @singpass_eservice_id = myinfo_config[:singpass_eservice_id]
      @private_key = myinfo_config[:private_key].gsub(/\n$/, '')
      @base_url = myinfo_config[:base_url]

      if @realm.nil? || @app_id.nil? || @singpass_eservice_id.nil? || @private_key.nil?
        fail 'Missing required argument(s) to initialize: realm, app_id, singpass_eservice_id, private_key'
      end
    end

    # call get_preson_basic api, receives NRIC/FIN, attributes to fetch, txn_no
    def get_person_basic(nric_fin: nil, attributes: nil, txn_no: Time.now.to_i) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      attributes ||= MY_INFO_PERSON_BASIC_ATTRIBUTES
      @timestamp = (Time.now.to_f * 1000).to_i
      @nonce = SecureRandom.hex
      url = "#{@base_url}#{ENDPOINT[:person_basic]}/#{nric_fin}/"

      base_string = formulate_base_string(
        http_method: 'GET', url: url, requested_attributes: attributes, txn_no: txn_no
      )
      puts "base_string: #{base_string}"

      signature = sign_base_string(base_string)
      puts "signature: #{signature}"

      auth_header = formulate_auth_header(signature)
      puts "auth_header: #{auth_header}"

      headers = formulate_headers(auth_header)
      puts "headers: #{headers}"

      full_url = formulate_url_with_query_string(url: url, attributes: attributes, txn_no: txn_no)
      puts "full_url: #{full_url}"

      option = { headers: headers }
      response = Http.get(full_url, option)
      puts "raw response: #{response}"
      if response.code == 200 && response.body
        json_string = decrypt_jwe(response.body.to_s)
        puts 'decrypted response: '
        { success: true, data: JSON.parse(json_string) }
      else
        { success: false, data: "#{response.code} - #{response.body}" }
      end
    rescue => error
      puts error
      { success: false, data: "#{error.class} - #{error.message}" }
    end

    private

    # decrypt raw response with private key
    def decrypt_jwe(body)
      key = OpenSSL::PKey::RSA.new File.read @private_key
      JWE.decrypt(body, key)
    end

    # construct base string
    def formulate_base_string(
      http_method: nil,
      url: nil,
      requested_attributes: nil,
      txn_no: nil
    )

      base_string_params = {
        "apex_l2_eg_app_id": app_id,
        "apex_l2_eg_nonce": @nonce,
        "apex_l2_eg_signature_method": 'SHA256withRSA',
        "apex_l2_eg_timestamp": @timestamp,
        "apex_l2_eg_version": 1.0,
        "attributes": requested_attributes.join(','),
        "client_id": @client_id,
        "singpassEserviceId": @singpass_eservice_id
      }
      base_string_params[:txnNo] = txn_no if txn_no

      "#{http_method.upcase}"\
        "&#{url.sub('.api.gov.sg', '.e.api.gov.sg')}"\
        "&#{URI.unescape(URI.encode_www_form(base_string_params.sort.to_h))}"
    end

    # sign base string using private key
    def sign_base_string(base_string)
      key = OpenSSL::PKey::RSA.new File.read @private_key
      signature = key.sign(OpenSSL::Digest::SHA256.new, base_string)

      Base64.encode64(signature).delete("\n")
    end

    # construct auth header with signature
    def formulate_auth_header(signature)
      "Apex_l2_Eg realm=\"#{@realm}\",apex_l2_eg_app_id=\"#{@app_id}\","\
          "apex_l2_eg_nonce=\"#{@nonce}\",apex_l2_eg_signature_method=\"SHA256withRSA\","\
          "apex_l2_eg_signature=\"#{signature}\",apex_l2_eg_timestamp=\"#{@timestamp}\",apex_l2_eg_version=\"1.0\""
    end

    # construct header with auth_header
    def formulate_headers(auth_header)
      {
        'Content-Type' => 'application/json',
        'Authorization' => auth_header,
        'Content-Encoding' => 'gzip',
        'Accept' => 'application/json'
      }
    end

    # construct url with encoded query string
    def formulate_url_with_query_string(url: nil, attributes: nil, txn_no: nil)
      query_string = {
        attributes: attributes.join(','),
        client_id: @client_id,
        singpassEserviceId: @singpass_eservice_id,
        txnNo: txn_no
      }

      "#{url}?#{URI.encode_www_form(query_string)}"
    end
  end
end
