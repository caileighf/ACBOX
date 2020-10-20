import datetime
import time
import sys
import os
import threading
import logging
import json
import copy
import pprint
import traceback
import logging

import gpsd

data_file = 'data/gps_{}.log'.format(datetime.datetime.now().timestamp())

def write_to_json(data):
    with open(data_file, 'a+') as f:
        for packet in data:
            f.write(packet)

def main():
    logging.basicConfig(filename='logs/debug_{}.log'.format(datetime.datetime.now().timestamp()),
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.DEBUG)

    gpsd.connect()
    packet = gpsd.get_current()
    print(packet.position())

    while True:
        packet = gpsd.get_current()
        print(packet.position())
        

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
    except:
        traceback.print_exc()
        logging.exception('Caught exception in main()')
    finally:
        print('\n\tExiting...\n')
        sys.exit()