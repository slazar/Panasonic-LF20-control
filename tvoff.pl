#!/usr/bin/perl -w

# This program turns off the Panasonic TH47LF-20u Television
#
# 2013/04/19 Sean Lazar, Square, Inc.

# Requires Device-Serial perl module.
use Device::SerialPort;
use strict; use warnings;

#search for the serial device with regex, return full device path
sub findserial
{
    my $serialdevicename  = $_[0];

    #find the device
    my $dir = "/dev";
    my $serialfullpath = "";

    foreach my $file (<$dir/*>) {
        if ($file =~ m/$dir\/$serialdevicename/) {
            $serialfullpath = $file;
			return $serialfullpath;
        }
    }
    return $serialfullpath;
}

my $serialdevice = "";
#define the serial devices to check in regex format
my @serialdevices = ("tty\.PL2303.*", "tty\.usbserial", "tty.KeySerial.*");

#try each serialdevice regex to find the device
foreach (@serialdevices) {
	$serialdevice = findserial($_);
	last if $serialdevice ne "";
}
if ($serialdevice eq "") {	
    die "Can't find a serial device.";
}

# Constructor & Basic Values
my $ob = Device::SerialPort->new ($serialdevice) || die "Can't open $serialdevice:$!";
$ob->baudrate (9600) || die "fail setting baudrate";
$ob->parity ("none") || die "fail setting parity";
$ob->databits (8) || die "fail setting databits";
$ob->stopbits (1) || die "fail setting stopbits";
$ob->handshake ("none") || die "fail setting handshake";
$ob->dtr_active (1) || die "fail setting dtr_active";
$ob->write_settings || die "no settings";

sleep 1;

#Send STXPOFETX RS232 command to turn the TV OFF
my $pass = $ob->write("\x02POF\x03") or die ("Could not write to port: $!");

sleep 1;

undef $ob

