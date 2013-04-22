#!/usr/bin/perl -w

# This program sets up the Panasonic TH47LF-20u Television for Square Inforad
# displays. It includes all of the settings we want, except for Standby save.
# Panasonic did not document how to set standby save in their manual, and
# settings from other manuals don't seem to work. Setting Standby Save to off
# (serial) will allow you to turn the TV on when it is turned off.
#
# 2013/04/19 Sean Lazar, Square, Inc. - initial adaptation and full setup

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

my $pass;

print "Set your computer output to 1080p\n";
$_ = <STDIN>;

#set language
print "Setting OSD language to English\n";
$pass = $ob->write("\x02SSU:LNGUSA\x03") or die ("Could not write to port: $!");

sleep 3;

#get the time and day
my @days = ('Sun','Mon','Tue','Wed','Thur','Fri','Sat');

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

my $day = $days[$wday];
my $upperday = uc($day) . "\n"; #convert to uppercase

$upperday = substr($upperday, 0, 3); #truncate all but the first three characters

#set the day
print "Setting day to $upperday\n";
$pass = $ob->write("\x02TIM:DAY$upperday\x03") or die ("Could not write to port: $!");
sleep 3;

#add leading zeros on time
$hour = sprintf("%2d", $hour);
$hour=~ tr/ /0/;
$min = sprintf("%2d", $min);
$min=~ tr/ /0/;

#set the time
print "Setting time to $hour:$min\n";
$pass = $ob->write("\x02TIM:NOW0$hour$min\x03") or die ("Could not write to port: $!");
sleep 3;

#set current source as HDMI1
print "Setting HDMI1 as current source\n";
$pass = $ob->write("\x02IMS:HM1\x03") or die ("Could not write to port: $!");
sleep 3;

#set the sharpness
print "Setting sharpness to 15\n";
$pass = $ob->write("\x02VPC:SHP015\x03") or die ("Could not write to port: $!");
sleep 3;

#set pixel 1:1
print "Setting pixel 1:1 to on\n";
$pass = $ob->write("\x02DGE:DBD1\x03") or die ("Could not write to port: $!");
sleep 3;

#set standby save off (enables serial control when off)
#this doesn't work. I got it from another manual. There doesn't seem to be this
#setting in the manual for the LF20 series. Have to do this by infrared remote.
print "Setting standby to off\n";
$pass = $ob->write("\x02SSU:SSV0\x03") or die ("Could not write to port: $!");
sleep 3;

#set HDMI1 as initial source
print "Setting HDMI1 as initial source\n";
$pass = $ob->write("\x02OSP:IINHM1\x03") or die ("Could not write to port: $!");
sleep 3;

#set initial sound at 15
print "Setting initial sound to 15\n";
$pass = $ob->write("\x02OSP:IVL1015\x03") or die ("Could not write to port: $!");
sleep 3;

#Pause
print "Set your computer output to 720p\n";
$_ = <STDIN>;

#set overscan off
print "Setting overscan to off\n";
$pass = $ob->write("\x02DGE:OVS0\x03") or die ("Could not write to port: $!");
sleep 5;

#set current source as HDMI1
print "Setting HDMI1 as current source\n";
$pass = $ob->write("\x02IMS:HM1\x03") or die ("Could not write to port: $!");
sleep 3;

undef $ob


