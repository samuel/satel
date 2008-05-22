# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.

################################ Weather #####################################

my $wremote	= "www.weather.com";
my $wport	= 80;

# (international,city,state/country)
sub tell_weather {
	my($iaddr,$paddr,$proto,$line);

	my $inter = $_[0];
	my $city = $_[1];
	my $state = $_[2];

	$iaddr = inet_aton($wremote) || return;
	$paddr = sockaddr_in($wport, $iaddr) || return;
	$proto = getprotobyname('tcp') || return;

	socket(SOCK, PF_INET, SOCK_STREAM, $proto) || return;
	connect(SOCK, $paddr) || return;
	if (!$inter) { 
		$msg = "GET /weather/cities/us_${state}_${city}.html HTTP/1.0\n\n";
	} else {
		$msg = "GET /weather/cities/${state}__${city}.html HTTP/1.0\n\n";
	}

	send(SOCK, $msg, 0) || return;	# die "Cannot send query: $!";

	my($at,$location,$update,$sunrise,$sunset,$status,$temp,$wind,$humidity,$bar);
	while ($hrm = <SOCK>) {
		if ($hrm =~ /Sorry.*You have requested a page/) {
			priv_msg($from,"Sorry, www.weather.com reported an invalid url. Check your city/state!");
			return;
		}
 
		if ($hrm =~ /\<TITLE\>/) {
			$hrm =~ s/^.*Channel - //;
			$hrm =~ s/\<\/TITLE\>//;
			$hrm =~ s/\n//;
			$location = $hrm;
		}
		if ($hrm =~ /current conditions as reported/) {
			$hrm = <SOCK>; $hrm = <SOCK>; $hrm = <SOCK>;
			$hrm =~ s/\s*//;
			$hrm = substr($hrm,0,index($hrm,"<"));
			$at = $hrm;
		}
		if ($hrm =~ /Sans Serif\"\>last updated at /) {
			$hrm =~ s/.*updated at //;
			$hrm = substr($hrm,0,index($hrm,"<"));
			$update = $hrm;
		}
		if ($hrm =~ /Sunrise:/) {
			$hrm =~ s/^.*Sunrise:\<\/B\> //;
			$hrm =~ s/ local time.*//;
#			$hrm =~ s/\n//;
			$hrm = substr($hrm,0,index($hrm,"<"));
			$sunrise = $hrm;
		}
		if ($hrm =~ /Sunset:/) {
			$hrm =~ s/^.*Sunset:\<\/B\> //;
			$hrm =~ s/ local time.*//;
#			$hrm =~ s/\n//;
			$hrm = substr($hrm,0,index($hrm,"<"));
			$sunset = $hrm;
		}
		if ($hrm =~ /\<IMG SRC\=\"\/weather\/wx_icons\/current_D\//) {
			$hrm =~ s/^.*ALT=\"//;
			$hrm =~ s/\"\sWID.*//;
			$hrm =~ s/\<BR\>/ /;
			$hrm =~ s/\n//;
			$status = $hrm;
		}
		if ($hrm =~ /temp:/) {
			$hrm =~ s/.*temp: //;
			$hrm =~ s/\&deg.*//;
			$hrm =~ s/\n//;
			$temp = $hrm;
		}
		if ($hrm =~ /wind:/) {
			$hrm =~ s/.*wind:\<\/B\> //;
			$hrm =~ s/\<BR\>.*//;
			$hrm =~ s/\n//;
			$wind = $hrm;
		}
		if ($hrm =~ /humidity:/) {
			$hrm =~ s/.*humidity:\<\/B\> //;
			$hrm =~ s/\<BR\>//;
			$hrm =~ s/\n//;
			$humidity = $hrm;
		}
		if ($hrm =~ /barometer:/) {
			$hrm =~ s/.*barometer:\<\/B\> //;
			$hrm =~ s/\<BR\>//;
			$hrm =~ s/\n//;
			$bar = $hrm;
		}
	}

	#ok done getting the info..
	if (!$inter) {
		priv_msg($from,"${location} - Sunrise: $sunrise  Sunset: $sunset");
		priv_msg($from,"Last Updated: $update - Reported at: $at");
	} else {
		priv_msg($from,"Current Conditions for: ${location}");
	}
	priv_msg($from,"Status: $status - Temp: $temp - Wind: $wind");
	priv_msg($from,"Humidity: $humidity - Barometer: $bar");
}

sub getweather {
	return if ($level < 50);
	if ($#_ < 1) {
		priv_msg($from,"syntax: getweather [city] [state]");
		return;
	}

	my $city = $_[0];
	my $state = $_[1];

	if (!($city =~ /^\w*$/) || !($state =~ /^\w*$/)) {
		priv_msg($from,"syntax: getweather [city] [state]");
		return;
	}

	tell_weather(0,$city,$state);
}

sub getiweather {
	return if ($level < 50);
	if ($#_ < 1) {
		priv_msg($from,"syntax: getiweather [city] [country]");
		return;
	}

	my $city = $_[0];
	my $country = $_[1];

	if (!($city =~ /^\w*$/) || !($country =~ /^\w*$/)) {
		priv_msg($from,"syntax: getiweather [city] [country]");
		return;
	}

	tell_weather(1,$city,$country);
}

1;
