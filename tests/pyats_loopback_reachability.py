import re
import logging

from ats import aetest
from ats.log.utils import banner

#
# create a logger for this testscript
#
logger = logging.getLogger(__name__)

#
# Common Setup Section
#
class common_setup(aetest.CommonSetup):
    '''Common Setup Section
    Defines subsections that performs configuration common to the entire script.
    '''

    @aetest.subsection
    def check_topology(self,
                       testbed,
                       core1_name = 'core1',
                       core2_name = 'core2'):
        '''
        check that we have at least two devices and a link between the devices
        If so, mark the next subsection for looping.
        '''

        # abort/fail the testscript if no testbed was provided
        if not testbed or not testbed.devices:
            self.failed('No testbed was provided to script launch',
                        goto = ['exit'])

        # abort/fail the testscript if no matching device was provided
        for name in (core1_name, core2_name):
            if name not in testbed:
                self.failed('testbed needs to contain device {name}'.format(
                                        name=name,
                                    ),
                            goto = ['exit'])

        core1 = testbed.devices[core1_name]
        core2 = testbed.devices[core2_name]
        agg3 = testbed.devices['agg3']
        agg4 = testbed.devices['agg4']

        # add them to testscript parameters
        self.parent.parameters.update(core1 = core1, core2 = core2)

        # get corresponding links
        links = core1.find_links(core2)
        assert len(links) >= 1, 'require one link between core1 and core2'

        # save link as uut link parameter
        self.parent.parameters['uut_link'] = links.pop()


    @aetest.subsection
    def establish_connections(self, steps, core1, core2, agg3, agg4):
        '''
        establish connection to both devices
        '''

        with steps.start('Connecting to core1'):
            core1.connect()

        with steps.start('Connecting to core2'):
            core2.connect()

        with steps.start('Connecting to agg3'):
            agg3.connect()

        with steps.start('Connecting to agg4'):
            agg4.connect()

        # abort/fail the testscript if any device isn't connected
        if not core1.connected or not core2.connected:
            self.failed('One of the devices could not be connected to',
                        goto = ['exit'])

        if not agg3.connected or not agg4.connected:
            self.failed('One of the devices could not be connected to',
                        goto = ['exit'])


# Ping Testcase: leverage dual-level looping
@aetest.loop(device = ('core1', 'core2', 'agg3', 'agg4'))
class PingTestcase(aetest.Testcase):
    '''Ping test'''

    groups = ('basic', 'looping')

    @aetest.test.loop(destination = ('192.168.255.1', '192.168.255.2', '192.168.255.3',
                                     '192.168.255.4', '192.168.255.5', '192.168.255.6'))
    def ping(self, device, destination):
        '''
        ping destination ip address from device
        Sample of ping command result:
        ping
        Protocol [ip]:
        Target IP address: 10.10.10.2
        Repeat count [5]:
        Datagram size [100]:
        Timeout in seconds [2]:
        Extended commands [n]: n
        Sweep range of sizes [n]: n
        Type escape sequence to abort.
        Sending 5, 100-byte ICMP Echos to 10.10.10.2, timeout is 2 seconds:
        !!!!!
        Success rate is 100 percent (5/5), round-trip min/avg/max = 1/1/1 ms
        '''

        try:
            # store command result for later usage
            result = self.parameters[device].ping(destination)

        except Exception as e:
            # abort/fail the testscript if ping command returns any exception
            # such as connection timeout or command failure
            self.failed('Ping {} from device {} failed with error: {}'.format(
                                destination,
                                device,
                                str(e),
                            ),
                        goto = ['exit'])
        else:
            # extract success rate from ping result with regular expression
            match = re.search(r'Success rate is (?P<rate>\d+) percent', result)
            success_rate = match.group('rate')
            # log the success rate
            logger.info(banner('Ping {} with success rate of {}%'.format(
                                        destination,
                                        success_rate,
                                    )
                               )
                        )


class common_cleanup(aetest.CommonCleanup):
    '''disconnect from ios routers'''

    @aetest.subsection
    def disconnect(self, steps, core1, core2):
        '''disconnect from both devices'''

        with steps.start('Disconnecting from core1'):
            core1.disconnect()

        with steps.start('Disconnecting from core2'):
            core2.disconnect()

        with steps.start('Disconnecting from agg3'):
            agg3.disconnect()

        with steps.start('Disconnecting from agg4'):
            agg4.disconnect()


        if core1.connected or core2.connected:
            # abort/fail the testscript if device connection still exists
            self.failed('One of the two devices could not be disconnected from',
                        goto = ['exit'])

        if agg3.connected or agg4.connected:
            # abort/fail the testscript if device connection still exists
            self.failed('One of the two devices could not be disconnected from',
                        goto = ['exit'])


if __name__ == '__main__':

    # local imports
    import argparse
    from ats.topology import loader

    parser = argparse.ArgumentParser(description = "standalone parser")
    parser.add_argument('--testbed', dest = 'testbed',
                        type = loader.load)
    # parse args
    args, unknown = parser.parse_known_args()

    # and pass all arguments to aetest.main() as kwargs
    aetest.main(**vars(args))
