# Demo Script to verify sanity of network

*** Settings ***
# Importing test libraries, resource files and variable files.
Library        genierobot.GenieRobot

# we can also import variables from yaml
# Variables      test_vars.yaml

*** Variables ***
# Defining variables that can be used elsewhere in the test data.
# Can also be driven as dash argument at runtime

# Define the pyATS testbed file to use for this run
${testbed}      ./test_testbed.yml

# Genie Libraries to use
${trigger_datafile}     %{VIRTUAL_ENV}/projects/genie_libs/sdk/yaml/iosxe/trigger_datafile_iosxe.yaml
${verification_datafile}     %{VIRTUAL_ENV}/projects/genie_libs/sdk/yaml/iosxe/verification_datafile_iosxe.yaml

*** Test Cases ***
# Creating test cases from available keywords.

Initialize
    # Initializes the pyATS/Genie Testbed
    # pyATS Testbed can be used within pyATS/Genie
    use genie testbed "${testbed}"
    execute testcase    reachability.pyats_loopback_reachability.common_setup

Ping
    execute testcase     reachability.pyats_loopback_reachability.PingTestcase    device=core1
    execute testcase     reachability.pyats_loopback_reachability.PingTestcase    device=core2
    execute testcase     reachability.pyats_loopback_reachability.NxosPingTestcase    device=agg3
    execute testcase     reachability.pyats_loopback_reachability.NxosPingTestcase    device=agg4
    execute testcase     reachability.pyats_loopback_reachability.NxosPingTestcase    device=leaf5
    execute testcase     reachability.pyats_loopback_reachability.NxosPingTestcase    device=leaf6


# Verify Bgp Neighbors
Verify Bgp neighbors core1
    verify count "1" "bgp neighbors" on device "core1"
Verify Bgp neighbors core2
    verify count "1" "bgp neighbors" on device "core2"
Verify Bgp neighbors branch10-router10
    verify count "1" "bgp neighbors" on device "branch10-router10"


# Verify Bgp Routes
# Tags can be used to control the behavior of the tests, noncritical tests which
# fail, will not cause the entire job to fail

Verify Bgp routes core1
    [Tags]    noncritical
    verify count "3" "bgp routes" on device "core1"
Verify Bgp routes core2
    [Tags]    noncritical
    verify count "3" "bgp routes" on device "core2"
Verify Bgp routes branch10-router10
    [Tags]    noncritical
    verify count "3" "bgp routes" on device "branch10-router10"


# Verify OSPF neighbor counts
Verify Ospf neighbors agg3
    verify count "7" "ospf neighbors" on device "agg3"
Verify Ospf neighbors agg4
    verify count "7" "ospf neighbors" on device "agg4"
Verify Ospf neighbors core1
    verify count "4" "ospf neighbors" on device "core1"
Verify Ospf neighbors core2
    verify count "4" "ospf neighbors" on device "core2"
Verify Ospf neighbors branch10-router10
    verify count "1" "ospf neighbors" on device "branch10-router10"

# Verify Interfaces
Verify Interace agg3
    verify count "74" "interface up" on device "agg3"
Verify Interace agg4
    verify count "74" "interface up" on device "agg4"
Verify Interace core1
    verify count "9" "interface up" on device "core1"
Verify Interace core2
    verify count "8" "interface up" on device "core2"
Verify Interace branch10-router10
    verify count "6" "interface up" on device "branch10-router10"
Verify Interace leaf5
    verify count "67" "interface up" on device "leaf5"
Verify Interace leaf6
    verify count "67" "interface up" on device "leaf6"

Terminate
    execute testcase "reachability.pyats_loopback_reachability.common_cleanup"
