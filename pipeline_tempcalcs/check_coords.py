#! /usr/bin/env python

import sys

def main():  
    """\
    A program to check the shape.dat file.
    """

    from argparse import ArgumentParser, RawDescriptionHelpFormatter
    from textwrap import dedent
    parser = ArgumentParser(description=dedent(main.__doc__),
                            formatter_class=RawDescriptionHelpFormatter)
    parser.add_argument('--version', action='version', version='%(prog)s 1.0')
    parser.add_argument('sFile', help='The shape.dat file.')
    args = parser.parse_args()

    x = []
    y = []
    z = []
    with open(args.sFile, 'r') as file:
         data = file.readlines ()
    for line in data:
        line = line.split()
        if len(line) == 7:
           if '=' in line:
              dip_num = int(line[0]) 
           else:
              x.append(int(line[1]))
              y.append(int(line[2]))
              z.append(int(line[3]))
             
    # wrong number of dipoles will give error message and stop the script
    if dip_num != len(x):
       print ("Wrong")
       sys.exit()

    # duplicate xyz coordinates will give error message and stop the script
    coord = [(x, y, z) for x, y, z in zip(x, y, z)]
    coord_new = set(coord)
    if len(coord) != len(coord_new):
       print ("Wrong")
       sys.exit()

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(1)
