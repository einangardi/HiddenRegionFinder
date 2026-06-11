HiddenRegionFinder development examples

Files:
  HiddenRegionFinder.wl
    Source-library version of the toolkit. 

  Examples/01_WideAngle_2to2_OffShell.wl
    Wide-angle 2->2 with off-shell external legs taken to zero.
    Includes Crown, SuperCrown and Diving Beetle examples.

  Examples/02_Forward_Regge_2to2_Massless.wl
    Forward/Regge 2->2 setup with massless external legs and s23/s12 counting.

  Examples/03_FivePoint_Spacelike_Collinear.wl
    Five-point spacelike collinear setup with the six-propagator seed graph.

Suggested workflow:
  1. Open Mathematica in this directory.
  2. Run Get["HiddenRegionFinder.wl"].
  3. Evaluate the example files section by section.

The examples are intentionally .wl source files rather than notebooks so that
they can be diffed and version-controlled easily.

Update: coverage-based LP scaling
---------------------------------
This revision adds findCoverageLPScaling and diagnostics for leading-support
coverage.  The replacement criterion requires all F_SL components to be
homogeneous at a common weight one power more singular than U, and requires
every active Lee--Pomeransky parameter to occur in the leading support of
F_SL/U/(optional F_obs).  The older findMinimalLPScaling is retained for
comparison.

New example objects include CoverageScalingTests2to2OffShell,
CoverageScalingTests2to2Forward, InteriorScalingData2Loop7Prop,
BoundaryScalingData2Loop7Prop, CoverageScalingFailures2Loop7Prop,
InteriorScalingData2Loop8Prop, BoundaryScalingData2Loop8Prop, and
CoverageScalingFailures2Loop8Prop.

Update: topology labels and paper-oriented summaries
---------------------------------------------------
03_FivePoint_Spacelike_Collinear.wl now attaches compact topology labels to
UFData2Loop7Prop and UFData2Loop8Prop.  The seed is G_bulletbullet.  A split of
the p3 vertex fills the first subscript, and a split of the p5 vertex fills the
second.  The channel labels are s for the pair {1,2}, t for {1,4}, and u for
{2,4} on the half of the opened vertex not carrying the external leg.

The example also creates:
  TopologySummary2Loop7Prop, TopologySummary2Loop8Prop
  TopologyRegionScalingSummary2Loop7Prop, TopologyRegionScalingSummary2Loop8Prop
  TopologyHiddenRegionRows2Loop7Prop, TopologyHiddenRegionRows2Loop8Prop

06_Topology_HiddenRegion_Summary.nb displays these tables and optionally exports
paper-oriented CSV summaries.
