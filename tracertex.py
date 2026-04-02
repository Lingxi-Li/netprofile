from argparse import ArgumentParser
from json import loads
from re import split, sub
from subprocess import PIPE, STDOUT, Popen

from requests import get


def fetch_info(ip):
    response = get(f'http://ipinfo.io/{ip}')
    if response.status_code != 200:
        raise Exception(f'HTTP {response.status_code}')
    info = loads(response.text)
    if 'bogon' in info: return 'LAN'    
    country = info['country']
    city = info["city"]
    isp = info['org'].split(' ', 1)[-1] if ('org' in info) else 'Unknown ISP'
    return f'{country}, {city}, {isp}'

def process_line(line):
    TIMEOUT = 'Timeout'
    line = line.rstrip().replace('Request timed out.', TIMEOUT)
    segs = split(' {2,}', line.lstrip())
    if len(segs) != 5 or segs[-1] == TIMEOUT:
        print(line)
    else:
        info = fetch_info(segs[-1])
        print(f'{line}\t{info}')


parser = ArgumentParser()
parser.add_argument('-dst', required=True, help='Target IP/hostname')
parser.add_argument('-hop', type=int, default=32, help='Max number of hops to search for target')
parser.add_argument('-ipv', choices=['4', '6'], help='Force using IPv4/v6')
args = parser.parse_args()
dst = args.dst
hop = args.hop
match args.ipv:
    case '4': ipopt = '-4'
    case '6': ipopt = '-6'
    case   _: ipopt = ''
try:
    cmdline = sub(' {2,}', ' ', f'tracert -d -h {hop} {ipopt} {dst}')
    print(cmdline)
    with Popen(cmdline, text=True, bufsize=1, stderr=STDOUT, stdout=PIPE) as p:
        while line := p.stdout.readline():
            process_line(line)
except KeyboardInterrupt:
    pass
except Exception as e:
    print(f'{type(e).__name__}: {e}')
