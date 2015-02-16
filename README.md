
check_volfree - Nagios NRPE plugin for windows, ver. 2015.02.15

Usage: check_volfree.vbs -l label -w <warn> -c <crit> | -h

Command-line options:
   -l, --label <label>  : Disk volume label
   
   -w, --warn <warn>    : set WARNING state
   
   -c, --crit <crit>    : set CRITICAL state
   
   -h, --help           : print this help message
   
Example:
   check_volfree.vbs -l SQLDATA -w 75 -c 85

   Check the utilization of the volume named SQLDATA;
   return WARNING if utilization is over 75%;
   return CRITICAL if above 85%
