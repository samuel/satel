# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.

my (@mudusers) = ("Descolada","Dive","ZeEric");

# +brief
# +autoloot
# +autosplit
# -autoexit
# -prompt
# +compact
# -echo

my $mudoutall = 0;
my $mudsname = "sotm";
my $mudirc = "#fisgames";
my $mudnick = "Satel";
my $mudpass = "cameltow";
my $mhand,@ohand;

sub mud_send {
	return if (!$mhand);
	print $mhand join(" ",@_);
}

sub mudsay {
	return if ($level < 50);
	mud_send("say ".join(" ",@_)."\n");
}

sub muddo {
	return if ($level < 50);
	mud_send(join(" ",@_)."\n");
}

sub mudconnect {
	return if ($level < 50);
	print_LOG("connection to MUD requested by $uname\n");
	if ($mhand) {
		print_LOG("... already connected to MUD\n");
		return;
	}
	mud_connect;
}

sub mudquit {
	return if ($level < 50);
	print_LOG("quit from MUD requested by $uname\n");
	if (!$mhand) {
		print_LOG("... not connected to MUD\n");
		return;
	}
#	mud_quit

	print_LOG("quitting from mud\n");
	mud_send("quit\n");
	close($mhand);
	$mhand = 0;
}

sub mudcmd {
	return if ($level < 50);
	return if (!$mhand);
	print $mhand "t satel satel ".join(" ",@_)."\n";
}

sub mud_connect {
	my $tmp;

	@ohand = ();

	print_LOG("Attempting to connect to dns.icubed.com:4444\n");

	$mhand = IO::Socket::INET->new(Proto => "tcp",
					PeerAddr => "dns.icubed.com",
					PeerPort => "4444") ||
		print_LOG("Unable to connet to dns.icubed.com:4444\n");

	return if (!$mhand);
	$mhand->autoflush(1);

	print_LOG("Connected\ to dns.icubed.com:4444\n");

	read($mhand,$a,1269);
	print $mhand "$mudnick\n";

	read($mhand,$a,10);
	print $mhand "$mudpass\n";

	my $ok, $line, $muduser;

	$SIG{CHLD} = sub { wait };

	print_LOG("forking mud app...\n");
	return if (fork);
	print_LOG("child here\n");

	sub mud_do_cmd {
		@cmds = split(" ",$_[0]);

		return if ($cmds[0] ne lc($mudnick));

		if ($cmds[1] eq "follow") {
			if ($cmds[2] eq "me") {
				print $mhand "follow $muduser\n";
			} elsif ($cmds[2] eq "stop") {
				print $mhand "follow $mudnick\n";
			} else {
				print $mhand "say $muduser, umm, do you want me to follow you?\n";
			}
		} elsif ($cmds[1] eq "tell") {
			shift @cmds; shift @cmds;
			priv_msg($mudirc,"<$muduser\@$mudsname> ".join(" ",@cmds)."\n");
		} elsif ($cmds[1] eq "leave") {
			print $mhand "say forget you then!\n";
			print $mhand "quit\n";
		} elsif ($cmds[1] eq "get") {
			print $mhand "get $cmds[2]\n";
		} elsif ($cmds[1] eq "do") {
			shift @cmds; shift @cmds;
			print $mhand join(" ",@cmds)."\n";
		} elsif ($cmds[1] eq "set") {
			if ($cmds[2] eq "outall") {
				$mudoutall = 0;
				if ($cmds[3] eq "on") {
					$mudoutall = 1;
				}
			}
		} elsif ($cmds[1] eq "connect") {
			$tmp = IO::Socket::INET->new(Proto => "tcp",
							PeerAddr => $cmds[2],
							PeerPort => $cmds[3]) ||
				print_LOG("Unable to connet to $cmds[2]:$cmds[3] for mud output\n");

			return if (!$tmp);
			$tmp->autoflush(1);
			push @ohand,$tmp;
		} elsif ($cmds[1] eq "disconnect") {
			if (@ohand) {
				$tmp = pop(@ohand);
				close($tmp);
			}
		}
	}

	while (<$mhand>) {
		$line = substr($_,1,length($_));
		chomp $line;
		if ($mudoutall) {
			priv_msg($mudirc,"<sotm> ".$line);
			select(undef, undef, undef, 0.5)
		}
		if (@ohand) {
			foreach $tmp (@ohand) {
				print $tmp "$line\n";
			}
		}
		if ($line =~ /^Press Return to Continue/) {
			print $mhand "\n";
		} elsif (($line =~ /^.* says '.*'./) ||
			 ($line =~ /^.* tells the group '.*'./) ||
			 ($line =~ /^.* tells you '.*'./)) {
			$ok = 0;
			foreach $i (@mudusers) {
				if ($line =~ /$i/) {
					$ok = 1;
					$muduser = $i;
					last;
				}
			}
			if ($ok) {
				$line = substr($line,index($line,"'")+1,length($line));
				$line = substr($line,0,rindex($line,"'"));
				mud_do_cmd($line);
			}
		} elsif ($line =~ /^You tell $mudnick/) {
			$line = substr($line,index($line,"'")+1,length($line));
			$line = substr($line,0,rindex($line,"'"));
			mud_do_cmd($line);
		}
	}

	exit 0;
}

sub mud_quit {
	return if (!$mhand);
	print_LOG("quitting from mud\n");
	mud_send("quit\n");
	close($mhand);
	$mhand = 0;
}

1;