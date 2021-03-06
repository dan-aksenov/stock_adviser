#!/usr/bin/env python
"""
    Small example of interaction with Moscow Exchange ISS server.

    Version: 1.1
    Developed for Python 2.6

    Requires iss_simple_client.py library.
    Note that the valid username and password for the MOEX ISS account
    are required in order to perform the given request for historical data.

    @copyright: 2016 by MOEX
"""

import sys
import datetime
import csv
#json to read config file
import json

from iss_simple_client import Config
from iss_simple_client import MicexAuth
from iss_simple_client import MicexISSClient
from iss_simple_client import MicexISSDataHandler
            
class MyData_print:
    def __init__(self):
        self.history = []

    def print_history(self):
        for sec in self.history:
            print sec

class MyData_tofile():
    """ Container that will be used by the handler to store data.
    Kept separately from the handler for scalability purposes: in order
    to differentiate storage and output from the processing.
    """
    def __init__(self):
        self.history = []

    def print_history(self):
        with open(outfile,'ab') as resultFile:
            wr = csv.writer(resultFile, delimiter='\t')
            wr.writerows(self.history)

#class MyData_todb():
#psycopg copy to behere. or separate file?
            
class MyDataHandler(MicexISSDataHandler):
    """ This handler will be receiving pieces of data from the ISS client.
    """
    def do(self, market_data):
        """ Just as an example we add all the chunks to one list.
        In real application other options should be considered because some
        server replies may be too big to be kept in memory.
        """
        self.data.history = self.data.history + market_data

def config(config_file):
   try:
        with open(config_file) as config_file:    
            conn_data = json.load(config_file)
   except:
        print "Error: Unable to read config file. "
        sys.exit(1)

   username = conn_data['username']
   password = conn_data['password']
   my_config = Config(user=username, password=password, proxy_url='')
   return my_config

def main():
    """Get current day's data and display print it on screen."""
    #my_config = Config(user=raw_input('username:'), password=raw_input('password:'), proxy_url='')
    my_config = config(config_file=raw_input('config file: ')) 
    my_auth = MicexAuth(my_config)
    """ Current date doesn't work during trade day. Can be run on evening after."""
    now = datetime.datetime.now() - datetime.timedelta(days=1)
    if my_auth.is_real_time():
        iss = MicexISSClient(my_config, my_auth, MyDataHandler, MyData_print)
        iss.get_history_securities('stock',
                                   'shares',
                                   'tqbr',
                                   now.strftime("%Y-%m-%d"))
        iss.handler.data.print_history()

def get_multiple( days_cnt, out_file, config_data ):
    """ Loop function to get ranges of dates. """
    global outfile
    outfile = out_file
    now = datetime.datetime.now()
    befoure = now - datetime.timedelta(days=days_cnt)
    delta = now - befoure
    my_config = config( config_data ) 
    my_auth = MicexAuth( my_config )
    #my_data = MyData_tofile(outfile)
    
    for i in range(delta.days + 1):
        dt = befoure + datetime.timedelta(days=i)
        if my_auth.is_real_time():
            iss = MicexISSClient(my_config, my_auth, MyDataHandler, MyData_tofile)
            iss.get_history_securities('stock',
                                   'shares',
                                   'tqbr',
                                   dt.strftime("%Y-%m-%d"))
            iss.handler.data.print_history()
        
if __name__ == '__main__':
    try:
        main()
    except:
        print "Sorry:", sys.exc_type, ":", sys.exc_value
