#!/usr/bin/env python3
from enum import Enum
import os
import subprocess
import ipaddress

colorkey = {
    'wifi': {
        'disconnected': '#dc322f',
        'connected': '#85c000',
        'connecting': '#cccc00',
    },
    'ethernet': {
        'disconnected': '#dc322f',
        'connected': '#859900',
        'connecting': '#b58900',
    },
    'bt': {
        'disconnected': '#dc322f',
        'connected': '#85c000',
        'connecting': '#cccc00',
    },
    'tun': {
        'connected': '#30b8b0',
        'connecting': '#268bd2',
        'disconnected': '#dc322f',
    },
    'loopback': {
        'unmanaged': '#93a1a1'
    }
}

class NMDev:
    name = ''
    method = None
    connection = None
    address = None
    state = None
    color = None
    def __init__(self):
        pass
    def __str__(self):
        return ''.join([
                '[not connected] ' if self.state == False else '',
                f'{self.method}|' if self.method is not None else '',
                f'{self.connection} ' if self.connection != "--" else '',
                f'{self.name} ' if self.name is not None else '',
                f'{self.address.ip}' if self.address is not None else '',
        ])

    def icon(self, small=False):
        if self.method == 'wifi':
            s = ''
        elif self.method == 'ethernet':
            s = ''
        elif self.method == 'bt':
            s = ''
        elif self.method == 'tun':
            s = '嬨'
        return s if small else '<span size="x-large">' + s + '</span>'

    def block_text(self):
        s = []
        e = []
        if self.color is not None:
            s.append('<span foreground="{}">'.format(self.color))
            e.insert(0, '</span>')
        s.append(self.icon())
        if self.connection != '--' and self.method != 'ethernet':
            s.append(f' {self.connection}')
        s.append('<small> ')
        e.insert(0, '</small>')
        if self.address is not None:
            s.append(str(self.address.ip))
        s.extend(e)
        return ''.join(s)

    def short_text(self):
        s = []
        e = []
        if self.color is not None:
            s.append('<span foreground="{}">'.format(self.color))
            e.insert(0, '</span>')
        s.append(self.icon(small=True))
        s.append('<small>')
        e.insert(0, '</small>')
        if self.connection != '--':
            s.append(f'{self.connection} ')
        s.extend(e)
        return ''.join(s)

button = os.environ.get('BLOCK_BUTTON')
if button == '1':
    subprocess.Popen(['nohup', 'nm-connection-editor'],
            stdout=open('/dev/null', 'w'),
            stderr=open('/dev/null', 'w'),
            preexec_fn=os.setpgrp
    )
elif button == '3':
    subprocess.Popen(['nohup', 'sys-notif', 'ip'],
            stdout=open('/dev/null', 'w'),
            stderr=open('/dev/null', 'w'),
            preexec_fn=os.setpgrp
    )

devs = []
with subprocess.Popen(['nmcli', 'device', 'show'], stdout=subprocess.PIPE) as p:
    device = NMDev()
    color = None
    for line in iter(p.stdout.readline, ''):
        # end of input
        if line == b'': break
        # end of current device
        if line == b'\n':
            if device is not None:
                devs.append(device)
            device = NMDev()
            color = None
        line = line.decode()
        if 'DEVICE' in line:
            device.name = line.split()[1]
        elif 'TYPE' in line:
            device.method = line.split()[1]
            for key, value in colorkey.items():
                if key in line:
                    color = value
                    break
        elif '4.ADDRESS' in line:
            device.address = ipaddress.ip_interface(line.split()[1])
        elif 'CONNECTION' in line:
            device.connection = ' '.join(line.split()[1:])
        elif 'STATE' in line:
            device.state = line.split()[2]
            if color is not None:
                for key, value in color.items():
                    if key in line:
                        device.color = value
                        break

    devs.append(device)

    print(' '.join(d.block_text() for d in devs if d.method != 'loopback'))
    print(' '.join(d.short_text() for d in devs if d.method != 'loopback'))
