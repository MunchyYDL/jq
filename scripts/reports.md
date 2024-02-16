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

### Unmarshalling with filtering

```shell
jq --slurpfile vins ./vins.json '
  import "scripts/funcs" as f;
  f::init | f::keep($vins | .[])
' ./input/dynamo.json > ./input/filtered.json
```
> Example of unmarshalling & filtering the dataset by a list of VINS.


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
' ./input/data.json > ./output/cars-grouped-current-owners-count.json
```

### Cars with 0 owners

```shell
jq '
  import "scripts/funcs" as f;
  f::active | f::owners_eq(0) | f::proj_vin_array
' ./input/data.json > ./output/cars-with-0-owners.json
```

### Report - Vehicle details for cars with 1 owner

This produces a list of vins, with the additional details of the owners.

```shell
jq '
  import "scripts/funcs" as f;
  f::active | f::owners_eq(1) | f::proj_details
'./input/data.json > ./output/cars-with-1-owners.json
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
