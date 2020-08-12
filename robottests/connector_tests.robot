#ENTSOE CONNECTOR TESTS
*** Settings ***
Library           Collections
Library           DateTime
Library           PoTLib
Library           REST         ${POT_API_URL}


*** Variables ***
${POT_API_URL}               http://localhost:8080
${APP_TOKEN}                 eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzY29wZSI6bnVsbCwiZXhwIjoxNTkwNTYxMDA2LCJpZCI6IjlmYzZhMDNiLTkwYWItNGRmZi05NGZkLWE5NDk1N2NjOTc1NyIsInN1YiI6ImVmN2ZkZDEwLWJiN2ItNDNmZi04OTgzLTYyMDQ2MzkwMWYzOSIsImF1ZCI6ImY3NzNkYWZlLTIwYzAtNGEyNS1hYTNlLTlkYTBiODFiOTMwNCIsInR5cGUiOiJVc2VyIiwiaXNzIjoiUG9ULXNhbmRib3giLCJpYXQiOjE1OTA0NzQ2MDYuMCwic2NvcGVzIjoiIn0.VRNF0jwkRrP32jPiGZwYmY6g5yA45j5DAguwwmNaGbAsSixhxhNo1IRQt_2Ka5RWPeVBojkPQyc_JCkoqZnGmsYEwjuiI7mT63KdUuzo4-RmarWvFA45pQpuDYAwRWHCT6IB8aSiqm-nTI2D6A12c2jwYN2tQS5yMltxSIcc3G9daZJq9fQ2lZPjtwbzzghN71GRglGGMox2GbEPyCM-WvzJ-9muhFra9sfOBzyHyvumCResPE_cYcwlqov6deNlGPIlCekO7FeuRv8ObPYuNTVrGL029ayic3BTIQNqj_Qqv9tqCsWD-lur93-N217MA57A7dzqOPOwtvWgxHjqSG_MOiiaDXRQ_9zIJ8zw8UU58YVQjeHphbr3rRP2-mvzPCSXM3kUX00kktrZrZ8eaeDnIBw2JA_ZOWHUmNctGWltURhRxLXINkQNnip56Y_0XrULs09kvOS0yEROOD93PV_8DPaOXVTPLIgnPrV8UsgywjwOH7AiqL5e6CYW8ESG1nxeTxYskKVlvfw1J4NADIMnGu0osst9PjsZKSK8khoZCggE27xPWfjI1EfXHYiDW_Q8e8B9tuY8SWeVqOt6yKbBUEKCcS8yqR-zAwaifk0owXfRSKrA_BP-yg7Dqeq45o3zAzzJx9O1pMxXOu_YsSyYd7TICW58taK9hWIW27I
${CLIENT_SECRET}             a
${PRODUCT_CODE}              entsoe-electricity-price-product-code
${TIMESTAMP}                 2018-11-01T12:00:00+00:00
${PERIOD}                    2020-06-08T13:00Z/2020-06-09T22:00Z
${PERIOD_SWAP}               2020-06-09T22:00Z/2020-06-08T13:00Z
${TARGETOBJECT}              10YFI-1--------U
${PRODUCTCODE}               entsoe-electricity-price-product-code
&{BROKER_BODY_PARAMETERS}    period=${PERIOD}
...                          targetObject=${TARGETOBJECT}
&{BROKER_BODY}               timestamp=${TIMESTAMP}
...                          productCode=${PRODUCT_CODE}
...                          parameters=${BROKER_BODY_PARAMETERS}

*** Keywords ***
Fetch Data Product
    [Arguments]     ${body}
    ${signature}    Calculate PoT Signature          ${body}    ${CLIENT_SECRET}
    Set Headers     {"x-pot-signature": "${signature}", "x-app-token": "${APP_TOKEN}"}
    POST            /translator/v1/fetch    ${body}
    Output schema   response body

Get Body
    [Arguments]          &{kwargs}
    ${body}              Copy Dictionary     ${BROKER_BODY}    deepcopy=True
    ${now}               Get Current Date    time_zone=UTC     result_format=%Y-%m-%dT%H:%M:%S+00:00
    Set To Dictionary    ${body}             timestamp         ${now}
    Set To Dictionary    ${body}             &{kwargs}
    ${json_string}=      evaluate        json.dumps(${body})                 json
    [Return]             ${json_string} 


*** Test Cases ***
fetch, 200
    ${body}                 Get Body
    Fetch Data Product      ${body}
    Integer                 response status                                         200
    String                  response body @context                                  https://standards-ontotest.oftrust.net/v2/Context/DataProductParameters/Forecast/Price/Electricity/
    Object                  response body data
    Array                   response body data forecasts
    String                  response body data forecasts 0 @type                    ForecastElectricityPriceMWH
    String                  response body data forecasts 0 period                   07.06.2020/09.06.2020
    Array                   response body data forecasts 0 pricePlans
    Object                  response body data forecasts 0 pricePlans 0             {"@type": "pricePlan","currency": "EUR","period": "07.06.2020T22:00/1h","rate": 3.68}
    String                  response body data forecasts 0 pricePlans 0 @type       pricePlan
    String                  response body data forecasts 0 pricePlans 0 currency    EUR
    String                  response body data forecasts 0 pricePlans 0 period      07.06.2020T22:00/1h
    Number                  response body data forecasts 0 pricePlans 0 rate        3.68

fetch, 422, Missing data for parameters required field
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')    json
    Pop From Dictionary    ${body}                              parameters
    Fetch Data Product     ${body}
    Integer                response status                                          422
    Integer                response body error status                               422
    String                 response body error message parameters 0                 Missing data for required field.    

fetch, 422, missing period field in parameters
    ${body}                Get Body
    ${body}=               evaluate        json.loads('''${body}''')                json
    Pop From Dictionary    ${body["parameters"]}                                    period
    Fetch Data Product     ${body}
    Integer                response status                                          422
    Integer                response body error status                               422
    String                 response body error message parameters.period 0          Missing data for required field. 

fetch, 422, missing targetObject field in parameters
    ${body}                Get Body
    ${body}=               evaluate        json.loads('''${body}''')                json
    Pop From Dictionary    ${body["parameters"]}                                    targetObject
    Fetch Data Product     ${body}
    Integer                response status                                          422
    Integer                response body error status                               422
    String                 response body error message parameters.targetObject 0    Missing data for required field. 

fetch, 200, period's first time parameter is bigger than second 
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')                  json
    Set To Dictionary      ${body["parameters"]}                                    period=${PERIOD_SWAP}
    ${body}=             evaluate        json.dumps(${body})                        json
    Fetch Data Product     ${body}
    Integer                 response status                                         200
    String                  response body @context                                  https://standards-ontotest.oftrust.net/v2/Context/DataProductParameters/Forecast/Price/Electricity/
    Object                  response body data
    Array                   response body data forecasts
    String                  response body data forecasts 0 @type                    ForecastElectricityPriceMWH
    String                  response body data forecasts 0 period                   07.06.2020/09.06.2020
    Array                   response body data forecasts 0 pricePlans
    Object                  response body data forecasts 0 pricePlans 0             {"@type": "pricePlan","currency": "EUR","period": "07.06.2020T22:00/1h","rate": 3.68}
    String                  response body data forecasts 0 pricePlans 0 @type       pricePlan
    String                  response body data forecasts 0 pricePlans 0 currency    EUR
    String                  response body data forecasts 0 pricePlans 0 period      07.06.2020T22:00/1h
    Number                  response body data forecasts 0 pricePlans 0 rate        3.68