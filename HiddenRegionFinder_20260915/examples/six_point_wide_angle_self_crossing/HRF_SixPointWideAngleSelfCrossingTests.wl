$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF6SelfCrossingAuditLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_SixPointWideAngleSelfCrossingAudit.wl"}]];

audit = hrf6SelfCrossingAudit[];
tests = {
  VerificationTest[
    audit["PhysicalKinematics", "AllMasslessQ"], True,
    TestID -> "physical-path-massless"],
  VerificationTest[
    audit["PhysicalKinematics", "MomentumConservationQ"], True,
    TestID -> "physical-path-conserves-momentum"],
  VerificationTest[
    audit["PhysicalKinematics", "SelfCrossingPathQ"], True,
    TestID -> "u-to-one-and-v-equals-w"],
  VerificationTest[
    audit["BoundaryLandauLocus", "FactorizationIdentityQ"], True,
    TestID -> "boundary-factorization"],
  VerificationTest[
    audit["BoundaryLandauLocus", "PositiveStationaryPinchQ"], True,
    TestID -> "positive-stationary-pinch"],
  VerificationTest[
    audit["CoreHRF", "HiddenRegionQ"], True,
    TestID -> "core-hrf-detection"],
  VerificationTest[
    audit["CoreHRF", "Scaling"], {-1, -1, -1, -1},
    TestID -> "active-scaling"],
  VerificationTest[
    {audit["CoreHRF", "WSL"], audit["CoreHRF", "WHR"]}, {-2, -1},
    TestID -> "weight-gap"],
  VerificationTest[
    audit["PhysicalExpansion", "OriginalRegionVector"],
    {0, -1, -1, 0, -1, -1, 1},
    TestID -> "original-coordinate-vector"],
  VerificationTest[
    audit["PhysicalExpansion", "BothDissectionChartsCertifiedQ"], True,
    TestID -> "both-dissected-lower-facets"],
  VerificationTest[
    audit["Inheritance", "NMRKFactorIdentitiesQ"], {True, True},
    TestID -> "nmrk-inherits-wide-angle-factors"],
  VerificationTest[
    audit["Inheritance", "DSCFactorIdentitiesQ"], {True, True},
    TestID -> "dsc-inherits-wide-angle-factors"],
  VerificationTest[
    audit["Conclusion"],
    <|"WideAngleBoundaryHiddenRegionQ" -> True,
      "CommonWideAngleSeedQ" -> True|>,
    TestID -> "final-conclusion"]
};

report = TestReport[tests];
summary = <|
  "Total" -> Length[tests],
  "Succeeded" -> report["TestsSucceededCount"],
  "Failed" -> report["TestsFailedCount"],
  "AllPassedQ" -> TrueQ[report["TestsFailedCount"] == 0]
|>;
Print[InputForm[summary]];
If[TrueQ[summary["AllPassedQ"]], Exit[0], Exit[1]];
