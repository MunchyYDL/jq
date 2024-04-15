import { allVins } from "./all_vins.testData";
import { salesforce } from "./salesforce.testData";
import { vdms as _vdms } from "./vdms.testData";

describe("produce set based results based on two arrays", () => {
  it("returns items unique to list 1", () => {
    const both = salesforce.filter((x) => allVins.includes(x));
    const sf_vins_not_in_vdms = salesforce.filter((x) => !allVins.includes(x));

    const sf_vins_in_vdms = salesforce.filter(
      (x) => !sf_vins_not_in_vdms.includes(x)
    );

    expect(both).toStrictEqual(sf_vins_in_vdms);

    const output = sf_vins_in_vdms;
    // eslint-disable-next-line no-console
    console.log(output.join("\n") + "\n\nlength: " + output.length);
  });
});
