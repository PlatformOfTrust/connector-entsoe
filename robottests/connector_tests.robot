#ENTSOE CONNECTOR TESTS
*** Settings ***
Library           Collections
Library           DateTime
Library           PoTLib
Library           REST         ${POT_API_URL}


*** Variables ***
${POT_API_URL}               http://localhost:8080
${APP_TOKEN}                 %{APP_TOKEN}
${CLIENT_SECRET}             %{CLIENT_SECRET}
${PRODUCT_CODE}              entsoe-electricity-price-product-code
${TIMESTAMP}                 2018-11-01T12:00:00+00:00
${PERIOD}                    2020-06-08T13:00Z/2020-06-09T22:00Z
${PERIOD_SWAP}               2020-06-09T22:00Z/2020-06-08T13:00Z
@{PERIOD_ARRAY}              2020-06-08T13:00Z/2020-06-09T22:00Z
${TARGETOBJECT}              10YFI-1--------U
${PRODUCTCODE}               entsoe-electricity-price-product-code
${PRODUCTCODE_WRONG}         entsoe-test
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
    String                  response body @context                                  https://standards.oftrust.net/v2/Context/DataProductOutput/Forecast/Price/Electricity/
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
    String                  response body @context                                  https://standards.oftrust.net/v2/Context/DataProductOutput/Forecast/Price/Electricity/
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

fetch, 200, period is array 
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')                  json
    Set To Dictionary      ${body["parameters"]}                                    period=${PERIOD_ARRAY}
    ${body}=             evaluate        json.dumps(${body})                        json
    Fetch Data Product     ${body}
    Integer                 response status                                         200
    String                  response body @context                                  https://standards.oftrust.net/v2/Context/DataProductOutput/Forecast/Price/Electricity/
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

fetch, 200, wrong product code
    ${body}                Get Body
    ${body}=             evaluate        json.loads('''${body}''')                  json
    Set To Dictionary      ${body}                                                  productCode=${PRODUCTCODE_WRONG}
    ${body}=             evaluate        json.dumps(${body})                        json
    Fetch Data Product     ${body}
    Integer                 response status                                         200
    String                  response body @context                                  https://standards.oftrust.net/v2/Context/DataProductOutput/Forecast/Price/Electricity/
    Object                  response body data
    Array                   response body data forecasts