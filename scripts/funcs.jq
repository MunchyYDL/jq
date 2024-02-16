  ## From AWS DynamoDB-JSON to JSON
  def unmarshal:
    if type == "object" then
      if has("S") then . = .S
      elif has("L") then . = .L
      elif has("M") then . = .M
      else . end
    else . end;

  def nonull:
    map(.owners |= if . == null then [] else . end);

  def init:
    [ .Items[] | walk(unmarshal) ];


  ## Filters - Owners

  def split:
    map(.active = (.owners | map(select(.unregisteredTimestamp == null)))) |
    map(.inactive = (.owners | map(select(.unregisteredTimestamp != null))));

  def active:
    map(.owners |= (map(select(.unregisteredTimestamp == null))));

  def owners_eq($n):
    map(select(.owners | length == $n ));
  def owners_gt($n):
    map(select(.owners | length > $n ));
  def owners_gte($n):
    map(select(.owners | length >= $n ));


  ## Filters - Models

  def model($n):
    map(select(.pno34 | startswith($n)));

  def model_ps1:
    model("232");
  def model_ps2:
    model("534");
  def model_ps3:
    model("359");
  def model_ps4:
    model("814");


  ## Filters - Vins

  def keep($items):
    map(select(.vin | contains($items | .[])));

  def keep(f; $items):
    map(select(f | contains($items | .[])));    

  ### Projections - Grouped

  def grouped_owners:
    map(.owners | length) 
    | group_by(.)
    | map({ ((first | tostring) + "_owners"): (. | length) })
    | add;

  def grouped_models:
    map(.pno34[:3])
    | group_by(.)
    | map({ ("model_" + (first | tostring)): (. | length) })
    | add;

  def grouped_regno:
    map(.registerNo | length)
    | group_by(.)
    | map({ ("regno_" + (first | tostring)): (. | length) })
    | add;

  def grouped_primary_driver:
    map(.primaryDriver | length)
    | group_by(.)
    | map({ (first | tostring): (. | length) })
    | add;


  # def grouped_structureWeek:
  #   map(.structureWeek)
  #   | group_by(.)
  #   | map({ ("model_" + (first | tostring)): (. | length) })
  #   | add;


  ### Projections - data

  def proj_owner:
    {
      salesforceId: .id,
      ownerType: .information.ownerType, 
      polestarId: .information?.polestarId,
      registeredAt: .registeredAt,
      unregisteredAt: .unregisteredTimestamp,
      active: (.unregisteredTimestamp == null)
    };

  def proj_details:
    map({
      vin: .vin,
      owners: (.owners | map(proj_owner) | sort_by(.registeredAt))
    })
    | sort_by(.vin);

  def proj_details_pd:
    map({
      vin: .vin,
      owners: (.owners | map(proj_owner) | sort_by(.registeredAt)),
      primaryDriver: .primaryDriver
    })
    | sort_by(.vin);

  def proj_structure_week:
    map({
      vin: .vin,
      structureWeek: .structureWeek
    })
    | sort_by(.vin);

  def proj_vin_array:
    map(.vin) | sort;
