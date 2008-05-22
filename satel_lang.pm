# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.

####################### DICTIONARIES and TRANSLATIONS ######################
sub defdict {
	return if ($level < 200); #$dw_level);

	my($defhand);

#	http://www.dictionary.com/cgi-bin/dict.pl?db=*&term=test
	$defhand = IO::Socket::INET->new(Proto     => "tcp",
					 PeerAddr  => "www.dictionary.com",
					 PeerPort  => "80") ||
		print_LOG("can't connect to port 2627 on www.dictionary.com in defdict\n");
	return if (!defined($defhand));
	$defhand->autoflush(1);

	print $defhand "GET /cgi-bin/dict.pl?db=*&term=test HTTP/1.0\n\n";

	close($defhand);
}

sub transit {
	return if ($level < $config{level_transit}); #$trans_level);
	if ($#_ < 1) {
		priv_msg($from,"syntax: transit <languages> <string>");
		return;
	}

	$SIG{CHLD} = sub { wait };

	if (!fork()) {
		$SIG{ALRM} = sub { exit 0 };
		alarm 15;

	my($defhand,$clen,$urltext,$trans);

	$defhand = IO::Socket::INET->new(Proto    => "tcp",
					 PeerAddr => "babelfish.altavista.com",
					 PeerPort => "80") ||
		print_LOG("can't connect to port 80 on babelfish.altavista.com in transit\n");
	if (!defined($defhand)) {
		priv_msg($from,"$unick, could not connect to babelfish.altavista.com");
		return;
	}
	$defhand->autoflush(1);

	$trans = $_[0];
	my($a,$b) = split('\+',join('+',@_),2);
	$b =~ s/\"/%22/g;
	$b =~ s/\'/%27/g;
	$b =~ s/,/%2C/g;
	$b =~ s/\?/%3F/g;
#	$clen = 27+length($b);
	$urltext = $b;
#	priv_msg($from,$urltext);
#	priv_msg($from,$clen);

#	print $defhand "POST /cgi-bin/translate? HTTP/1.1\n";
#	print $defhand "Accept: */*\n";
#	print $defhand "Referer: http://babelfish.altavista.digital.com/cgi-bin/translate?\n";
#	print $defhand "Accept-Language: en-us,fi;q=0.5\n";
#	print $defhand "ContentType: application/x-www-form-urlencoded\n";
##	print $defhand "Accept-Encoding: gzip, defalte\n";
#	print $defhand "User-Agent: satel (the omnipotent bot)\n";
#	print $defhand "Host: babelfish.altavista.digital.com\n";
#	print $defhand "Content-Length: $clen\n";
##	print $defhand "Connection: Keep-Alive\n\n";

#	print $defhand "doit=done&urltext=$urltext&lp=$trans\n\n";

	print $defhand "GET /cgi-bin/translate?doit=done&urltext=$urltext&lp=$trans HTTP/1.0\n\n";

#	priv_msg($from,"All sent, ready to go...");

	$j = 0;
	while (<$defhand>) {
		if ($_ =~ /\<font face=\"arial,\ helvetica\"\>/) {
			$_ =~ s/<.*>//g;
			$_ = join(" ",split(" ",$_));
			if ($_ ne "") {
				priv_msg($from,"$unick, $_");
				$j++;
			}
		}
	}
	if (!$j) {
		priv_msg($from,"$unick, no data received");
	}

#	priv_msg($from,"Done");

	close($defhand);

		exit 0;

	}
}

sub esptoeng {
	return if ($level < $config{level_esp});#$ee_level);
	my(@a,$word,$b);
	$word = lc($_[0]);
	open(TMPFILE,$esp_dict);
	$b = 1;
	while (<TMPFILE>) {
		@a = split(" ",$_);
		next if (substr($a[0],0,1) eq ";");
		if ($word eq lc($a[0])) {
			priv_msg($from,"$unick, $a[3]\[$a[1],$a[2]\]");
			$b = 0;
		}
	}
	close(TMPFILE);
	priv_msg($from,"$unick, word not found") if ($b);
}

sub engtoesp {
	return if ($level < $config{level_esp});#$ee_level);
	my(@a,$word,$b);
	$word = lc($_[0]);
	open(TMPFILE,$esp_dict);
	$b = 1;
	while (<TMPFILE>) {
		@a = split(" ",$_);
		next if (substr($a[0],0,1) eq ";");
		if ($word eq lc($a[3])) {
			priv_msg($from,"$unick, $a[0]\[$a[1],$a[2]\]");
			$b = 0;
		}
	}
	close(TMPFILE);
	priv_msg($from,"$unick, word not found") if ($b);
}

sub difinuvorto { defineword($_[0]) };
sub defineword {
	return if ($level < $config{level_dw}); #$dw_level);
	return if ($#_ < 0);

	my($i,$j,$defhand);#,$iaddr,$paddr);

#	if ($dw_fork) {
	if ($config{dw_fork}) {
		$SIG{CHLD} = sub { wait };
		$j = fork();
	} else {
		$j = 0;
	}

	if (!$j) {
#		if (($dw_fork) && ($dw_timeout != 0)) {
		if (($config{dw_fork}) && ($config{dw_timeout} != 0)) {
			$SIG{ALRM} = sub { exit 0 };
#			alarm $dw_timeout;
			alarm $config{dw_timeout};
		}

		$defhand = IO::Socket::INET->new(Proto     => "tcp",
						 PeerAddr  => "muesli.ai.mit.edu",
						 PeerPort  => "2627") ||
				print_LOG("can't connect to port 2627 on muesli.ai.mit.edu in defineword\n");
		return if (!defined($defhand));
		$defhand->autoflush(1);

#		$iaddr = gethostbyname("muesli.ai.mit.edu");
#		$paddr = sockaddr_in(2627,$iaddr);
#		socket(dSOCK, PF_INET, SOCK_STREAM, getprotobyname('tcp')) ||
#			print_LOG("can't create socket in defineword\n");
#		connect(dSOCK, $paddr) ||
#			print_LOG("can't connect to port 2627 on muesli.ai.mit.edu in defineword\n");
#		select(dSOCK);
#		$| = 1;
#		$defhand=dSOCK;
#		select($defhand);
#		$| = 1;

		print $defhand "DEFINE @_\n";
		print $defhand "SPELL garbage\n";
		$i = 0;
		while (<$defhand>) {
			last if ($_ =~ /SPELLING 1/);
			last if (index($_,chr(128)) >= 0);
			if ($dw_qm) {
				priv_msg($from,quotemeta $_);
			} else {
				priv_msg($from,$_);
			}
			if (($i++) >= $config{max_deflen}) {#$max_deflen) {
				priv_msg($from,"---TOO MANY LINES---");
				last;
			};
		}
		close($defhand);

#		close(dSOCK);

#		exit(0) if ($dw_fork);
		exit(0) if ($config{dw_fork});
	}
}

sub spellword {
	my($i,$j,$defhand,$iaddr,$paddr);
	return if ($level < $config{dw_level}); #$dw_level);
	return if ($#_ < 0);

#	if ($dw_fork) {
	if ($config{dw_fork}) {
		$SIG{CHLD} = sub { wait };
		$j = fork();
	} else {
		$j = 0;
	}
	if (!$j) {
#		if (($dw_fork) && ($dw_timeout != 0)) {
		if (($config{dw_fork}) && ($config{dw_timeout} != 0)) {
			$SIG{ALRM} = sub { exit 0 };
#			alarm $dw_timeout;
			alarm $config{dw_timeout};
		}

		$defhand = IO::Socket::INET->new(Proto     => "tcp",
						 PeerAddr  => "muesli.ai.mit.edu",
						 PeerPort  => "2627") ||
			print_LOG("can't connect to port 2627 on muesli.ai.mit.edu in defineword\n");

		return if (!defined($defhand));
		$defhand->autoflush(1);

		print $defhand "SPELL @_\n";
		print $defhand "DEFINE silicone\n";
		$i = 0;
		while (<$defhand>) {
			last if ($_ =~ /DEFINITION 0/);
			last if (index($_,chr(128)) >= 0);
			if ($dw_qm) {
				priv_msg($from,quotemeta $_);
			} else {
				priv_msg($from,$_);
			}
#			if (($i++) >= $max_deflen) {
			if (($i++) >= $config{max_deflen}) {
				priv_msg($from,"---TOO MANY LINES---");
				last;
			};
		}

		close($defhand);
#		exit(0) if ($dw_fork);
		exit(0) if ($config{dw_fork});
	}
}

1;