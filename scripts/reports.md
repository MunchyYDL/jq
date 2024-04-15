# Workflow

## Create working directory

```shell
cp -r dev now
```

## Zip the reports

```shell
zip reports.zip ./output/ -r
```

---

## Export AWS DynamoDB JSON

```shell
aws dynamodb scan \
  --table-name 'polestar360-prod-vehicle-api-back' \
  --projection-expression 'vin, pno34, owners, primaryDriver' \
  > ./input/dynamo.json
```

```shell
aws dynamodb scan \
  --table-name 'polestar360-prod-vehicle-api-back' \
  --projection-expression 'vin, owners, primaryDriver' \
  > ./input/dynamo.json
```

```shell
aws dynamodb scan \
  --table-name 'polestar360-prod-vehicle-api-back' \
  --projection-expression 'vin, owners' \
  > ./input/dynamo.json
```

```shell
aws dynamodb get-item \
  --table-name 'polestar360-staging-vehicle-api-back' \
  --key '{"vin":{"S":"LPSVSEDEEML950802"}}' \
  --projection-expression 'vin, owners' \
```

```shell
aws dynamodb get-item \
  --table-name 'polestar360-staging-vehicle-api-back' \
  --key '{"vin":{"S":"LPSVSEDEEML999171"}}' \
  --projection-expression 'vin, owners' \
```

```shell
aws dynamodb batch-get-item \
  --request-items file://request-items.json
```

### Telematics

FIXME: This failed because:

> _"An error occurred (ProvisionedThroughputExceededException) when calling the Scan operation (reached max retries: 2): The level of configured provisioned throughput for the table was exceeded. Consider increasing your provisioning level with the UpdateTable API."_

```shell
aws dynamodb scan \
  --table-name 'telematics-events-store' \
  --projection-expression 'vin, eventType, eventData, updatedTimestamp' \
  --filter-expression 'eventType = :eventType' \
  --expression-attribute-values '{":eventType":{"S":"OdometerUpdated"}}' \
  > ./input/dynamo.json
```

### AM Connect Export

```shell
aws dynamodb scan \
     --table-name 'polestar360-prod-vehicle-api-back' \
     --projection-expression 'vin, metaOrderNumber, modelYear, deliveryDate, market, registrationNo, registrationDate, structureWeek, factoryCompleteDate, drivetrain, software, salesType, commonStatusPoint, brandStatus, pno34, features' \
     > ./input/dynamo.json
```

### Filtering query

```shell
aws dynamodb scan \
     --table-name 'polestar360-prod-vehicle-api-back' \
     --filter-expression 'contains(pno34,:featureCode)' \
     --expression-attribute-values '{":featureCode":{"S":"001028"}}' \
     --select 'COUNT' \
     > ./output/ps3-towbar.json
```

```shell
aws dynamodb scan \
     --table-name 'polestar360-prod-vehicle-api-back' \
     --filter-expression 'begins_with(pno34, :model)' \
     --expression-attribute-values '{":model": {"S": "232"}}' \
     --projection-expression 'vin, pno34, owners, primaryDriver' \
     > ./input/dynamo.json
```

Exporting from the vehicle-api-data table in ICP

```shell
aws dynamodb scan \
     --table-name 'vehicle-api-data' \
     --projection-expression 'vin, internalCar, market, modelYear, pno34, structureWeek' \
     > ./input/dynamo.json
```

---

## Unmarshalling

```shell
jq '
  import "scripts/funcs" as f;
  f::init
' ./input/dynamo.json > ./input/data.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::init | f::not_null(.owners)
' ./input/dynamo.json > ./input/data.json
```

### Unmarshalling with filtering

```shell
jq --slurpfile vins ./input/vins.json '
  import "scripts/funcs" as f;
  f::init | f::keep($vins | .[])
' ./input/dynamo.json > ./input/data.json
```

```shell
jq --slurpfile vins ./output/vins.json '
  import "scripts/funcs" as f;
  f::init | f::keep($vins | .[])
' ./input/dynamo.json > ./input/data.json
```

> Example of unmarshalling & filtering the dataset by a list of VINS.

### Just filtering

```shell
jq --slurpfile vins ./input/vins.json '
  import "scripts/funcs" as f;
  f::keep($vins | .[])
' ./input/data.json > ./input/filtered.json
```

> Example of slurping a raw txt-file with data on each row

```shell
jq '
  import "scripts/funcs" as f;
  f::init | f::model_ps1
' ./input/dynamo.json > ./input/filtered.json
```

> Example of unmarshalling & filtering the dataset on a specific model(PS1).

---

## Reports - Owners

### Report - Grouped on current owner count

This produces a small overview report, grouped on the number of active owners a car has.

```shell
jq '
  import "scripts/funcs" as f;
  f::active | f::grouped_owners
' ./input/data.json > ./output/cars-grouped-active-owners-count.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::grouped_owners
' ./input/data.json > ./output/cars-grouped-all-owners-count.json
```

### Cars with 0 active owners

```shell
jq '
  import "scripts/funcs" as f;
  f::owners_eq(0) | f::proj_vin_array
' ./input/data.json > ./output/cars-with-0-owners.json
```

### Report - Vehicle details for cars with 1 owner

This produces a list of vins, with the additional details of the owners.

```shell
jq '
  import "scripts/funcs" as f;
  f::active
' ./input/data.json > ./output/cars-with-active-owners.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::active | f::owners_eq(0) | f::proj_vin_array
' ./input/data.json > ./output/cars-with-0-active-owners-list.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::active | f::owners_eq(0) | f::proj_details_pd
' ./input/data.json > ./output/cars-with-0-active-owners.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::active | f::owners_eq(1) | f::proj_details_pd
' ./input/data.json > ./output/cars-with-1-active-owner.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::active | f::owners_eq(2) | f::proj_details_pd
' ./input/data.json > ./output/cars-with-2-active-owners.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::active | f::owners_eq(3) | f::proj_details_pd
' ./input/data.json > ./output/cars-with-3-active-owners.json
```

### All owners

```shell
jq '
  import "scripts/funcs" as f;
  f::owners_eq(0) | f::proj_vin_array
' ./input/data.json > ./output/cars-with-0-all-owners-list.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::owners_eq(0) | f::proj_details_pd
' ./input/data.json > ./output/cars-with-0-all-owners.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::owners_eq(1) | f::proj_details_pd
' ./input/data.json > ./output/cars-with-1-all-owners.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::owners_eq(2) | f::proj_details_pd
' ./input/data.json > ./output/cars-with-2-all-owners.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::owners_eq(3) | f::proj_details_pd
' ./input/data.json > ./output/cars-with-3-all-owners.json
```

```shell
jq '
  import "scripts/funcs" as f;
  f::owners_eq(4) | f::proj_details_pd
' ./input/data.json > ./output/cars-with-4-all-owners.json
```

### Report

This produces a small overview report, grouped on the number of owners a car has,
including both active and inactive ones.

```shell
jq '
  import "scripts/funcs" as f;
  f::grouped_owners
' ./input/data.json > ./output/cars-grouped-all-owners-count.json
```

### Report - Vehicle details for all owners

```shell
jq '
  import "scripts/funcs" as f;
  f::proj_details
' ./input/data.json > ./output/cars-with-owners.json
```

### Report - Vehicle details including primaryDriver

This produces a list of vins, with additional details of the owners and primaryDriver.

```shell
jq '
  import "scripts/funcs" as f;
  f::proj_details_pd
' ./input/data.json > ./output/cars-with-owners.json
```

---

## Reports - Models

### Report - Grouped on model

This produces a small overview report, grouped on the model of the car.

```shell
jq '
  import "scripts/funcs" as f;
  f::grouped_models
' ./input/data.json > ./output/cars-grouped-models-count.json
```

### Report - All VINS for a specific model

This filters the list of cars on a specific model, and outputs the vins to a list.

```shell
jq '
  import "scripts/funcs" as f;
  f::model_ps4 | f::proj_vin_array
' ./input/data.json > ./input/cars-ps4.json
```

---

## Reports - Misc

### Report - All VINS

This is just a simple sorted list of all the vins extracted from the input data.

```shell
jq '
  import "scripts/funcs" as f;
  f::proj_vin_array
' ./input/data.json > ./output/all-vins.json
```

### Output to a raw file

Directly

```shell
jq -r '
  import "scripts/funcs" as f;
  f::proj_vin_array | .[]
' ./input/data.json > ./output/all-vins.txt
```

Or as a separate simple step

```shell
jq -r '
  .[]
' ./output/all-vins.json > ./output/all-vins.txt
```

### ICP - CarVis Test

```shell
jq '
  import "scripts/funcs" as f;
  [.[] | select(.internalCar) | {vin, market, modelYear, pno34, structureWeek}] | sort
' ./input/data.json > ./output/vehicles.json
```
