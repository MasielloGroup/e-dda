#! /usr/bin/env python

import sys

def main():  
    """\
    A program to check the temp.out file.
    """

    from argparse import ArgumentParser, RawDescriptionHelpFormatter
    from textwrap import dedent
    parser = ArgumentParser(description=dedent(main.__doc__),
                            formatter_class=RawDescriptionHelpFormatter)
    parser.add_argument('--version', action='version', version='%(prog)s 1.0')
    parser.add_argument('tFile', help='The temp.out file.')
    args = parser.parse_args()

    with open(args.tFile, 'r') as file:
         data = file.readlines()
    with open(args.tFile, 'r') as file:
         line = file.readlines()
    index = []
    for i in range(len(line)): 
        line[i] = line[i].split()
        if len(line[i]) != 6:
           index.append(i)
    data = data[len(index):]

    with open('temp.out', 'w') as file:
         file.writelines(data)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(1)
