require './my_info/api'

# inputs to MyInfo API
private_key = File.join(File.dirname(__FILE__), 'ssl/stg-demoapp-client-privatekey-2018.pem')
myinfo_config = {
  realm: 'some_string',
  app_id: 'STG2-MYINFO-SELF-TEST',
  singpass_eservice_id: 'MYINFO-CONSENTPLATFORM',
  private_key: private_key,
  base_url: 'https://myinfosgstg.api.gov.sg/gov/test/v2/'
}
nric_fin = 'S3000024B'

api = MyInfo::Api.new(myinfo_config)
requested_attributes = ['name', 'sex', 'race', 'dob', 'residentialstatus', 'regadd']

puts api.get_person_basic(nric_fin: nric_fin, attributes: requested_attributes)

