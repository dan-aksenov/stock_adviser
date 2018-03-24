import sys
from getopt import getopt
import time
import datetime
import iis_simple_main

def usage():
    print "Usage: -c config file path, -d number of days to download, -d dump directory"


def main():
    try:    
        opts, args = getopt( sys.argv[1:], 'c:b:d:' )
    except:
        usage()
        sys.exit(1)

    for opt, arg in opts:
        if opt in ( '-c' ):
            config_file = arg
        elif opt in ( '-b' ):
            days= arg
        elif opt in ( '-d' ):
            dump_path = arg
        else:
            usage()
            sys.exit(1)
'''
    try:
        config_file
    except:
        config_file = raw_input('Config file path: ')
    
    try:
        buck_name
    except:
        buck_name = raw_input('Bucket to dump:  ')
    
    try:
        dump_path
    except:
        dump_path = raw_input('Dump directory: ')
'''            
    start_time =  time.time()
    s3connect( config_file )
    print("Dumped on " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M"))
    buck_dump_diff( buck_name, dump_path )
    print("Backed up for %s seconds" % (time.time() - start_time))


if __name__ == '__main__':
    main()
