# Demo Script to verify sanity of network

*** Settings ***
# Importing test libraries, resource files and variable files.
Library        genierobot.GenieRobot
Variables      prod_vars.yaml

*** Variables ***
# Defining variables that can be used elsewhere in the test data.
# Can also be driven as dash argument at runtime

${testbed}      ./prod_testbed.yml
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
    verify count "${bgp_neighbors_core1}" "bgp neighbors" on device "core1"
Verify Bgp neighbors core2
    verify count "${bgp_neighbors_core2}" "bgp neighbors" on device "core2"
Verify Bgp neighbors branch10-router10
    verify count "${bgp_neighbors_branch10-router10}" "bgp neighbors" on device "branch10-router10"

# Verify Bgp Routes
Verify Bgp routes core1
    [Tags]    noncritical
    verify count "${bgp_routes_core1}" "bgp routes" on device "core1"
Verify Bgp routes core2
    [Tags]    noncritical
    verify count "${bgp_routes_core2}" "bgp routes" on device "core2"
Verify Bgp routes branch10-router10
    [Tags]    noncritical
    verify count "${bgp_routes_branch10-router10}" "bgp routes" on device "branch10-router10"

# Verify Interfaces
Verify Interace agg3
    [Tags]    noncritical
    verify count "${interface_agg3}" "interface up" on device "agg3"
Verify Interace agg4
    [Tags]    noncritical
    verify count "${interface_agg4}" "interface up" on device "agg4"
Verify Interace core1
    [Tags]    noncritical
    verify count "${interface_core1}" "interface up" on device "core1"
Verify Interace core2
    [Tags]    noncritical
    verify count "${interface_core2}" "interface up" on device "core2"
Verify Interace branch10-router10
    [Tags]    noncritical
    verify count "${interface_branch10-router10}" "interface up" on device "branch10-router10"
Verify Interace leaf5
    [Tags]    noncritical
    verify count "${interface_leaf5}" "interface up" on device "leaf5"
Verify Interace leaf6
    [Tags]    noncritical
    verify count "${interface_leaf6}" "interface up" on device "leaf6"

Terminate
    execute testcase "reachability.pyats_loopback_reachability.common_cleanup"
