# MyInfo API

Welcome! This document details the MyInfo API connectivity to test environment.

## Getting Started

### Prerequisites

ruby 2.3.1

jwe gem - used to decrypt the MyInfo response.

http gem -used to handle the http request.

> I have configured with `Test env MyInfo application id, Singpass e-service id and private key`


## Installing

```
gem install jwe
gem install http
```

### Update Config

To test MyInfo API using your own account. You need to get your Singpass E-service id, MyInfo Application id and your private key.

>Place your private key inside `ssl` folder.
Update Singpass E-service id, MyInfo Application id and path to private key in `test.rb`

### Running the test.rb
Go to root directory of the repo and run `ruby test.rb`

`Tada!!` you can see the `base_string`, `signature`, `auth_header`, `headers`, `full_url`, `raw_response`, `decrypted_response`(MyInfo response json)

**base_string:**
`GET&https://myinfosgstg.e.api.gov.sg/gov/test/v2/person-basic/S3000024B/&apex_l2_eg_app_id=STG2-MYINFO-SELF-TEST&apex_l2_eg_nonce=68327c579d9aa8979ad29d1563be9ac8&apex_l2_eg_signature_method=SHA256withRSA&apex_l2_eg_timestamp=1553742922582&apex_l2_eg_version=1.0&attributes=name,sex,race,dob,residentialstatus,regadd&client_id=STG2-MYINFO-SELF-TEST&singpassEserviceId=MYINFO-CONSENTPLATFORM&txnNo=1553742922`

**signature:** `Rc7q1jxuu........mF5JURsk8Qw==`

**auth_header:** `Apex_l2_Eg realm="some_string",apex_l2_eg_app_id="STG2-MYINFO-SELF-TEST",apex_l2_eg_nonce="68327c579d9aa8979ad29d1563be9ac8",apex_l2_eg_signature_method="SHA256withRSA",apex_l2_eg_signature="Rc7q1jxuu........mF5JURsk8Qw==",apex_l2_eg_timestamp="1553742922582",apex_l2_eg_version="1.0"`

**headers:** `{"Content-Type"=>"application/json", "Authorization"=>"Apex_l2_Eg realm=\"some_string\",apex_l2_eg_app_id=\"STG2-MYINFO-SELF-TEST\",apex_l2_eg_nonce=\"68327c579d9aa8979ad29d1563be9ac8\",apex_l2_eg_signature_method=\"SHA256withRSA\",apex_l2_eg_signature=\"Rc7q1jxuu........mF5JURsk8Qw==\",apex_l2_eg_timestamp=\"1553742922582\",apex_l2_eg_version=\"1.0\"", "Content-Encoding"=>"gzip", "Accept"=>"application/json"}`

**full_url:** `https://myinfosgstg.api.gov.sg/gov/test/v2/person-basic/S3000024B/?attributes=name%2Csex%2Crace%2Cdob%2Cresidentialstatus%2Cregadd&client_id=STG2-MYINFO-SELF-TEST&singpassEserviceId=MYINFO-CONSENTPLATFORM&txnNo=1553742922`

**raw response:**
`eyJlbmMiOiJBMjU2R0NNIiwiYW...............ngOYjzjdWUlqM3Q`

**decrypted response:**
`{:success=>true, :data=>{"residentialstatus"=>{"lastupdated"=>"", "source"=>"1", "classification"=>"C", "value"=>""}, "dob"=>{"lastupdated"=>"2017-12-18", "source"=>"1", "classification"=>"C", "value"=>"1974-05-11"}, "name"=>{"lastupdated"=>"2017-12-18", "source"=>"1", "classification"=>"C", "value"=>"LEE HUI LING"}, "regadd"=>{"country"=>"SG", "source"=>"1", "classification"=>"C", "building"=>"BRADDELL VIEW", "unit"=>"4", "street"=>"BRADDELL HILL", "lastupdated"=>"2017-12-19", "block"=>"10G", "postal"=>"579726", "floor"=>"5"}, "race"=>{"lastupdated"=>"2017-12-18", "source"=>"1", "classification"=>"C", "value"=>"CN"}, "sex"=>{"lastupdated"=>"2017-12-18", "source"=>"1", "classification"=>"C", "value"=>""}}}`

### Trouble Shooting

1. When running `ruby test.rb`. If you see a response with following error message

`{"code": 401,"message": "Invalid SingPass Login", "fields": ""}`

>MyInfo Api requires a valid Singpass session to return response i.e., MyInfo is validating requested NRIC has any active Singpass session.

To fix this, you need to login using the NRIC(mentioned in test.rb) into Staging Singpass. After successful login, try running the same and you see the success response.
