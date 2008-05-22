# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.

sub send_file {
# params
#  0 mail server
#  1 file to send
#  2 subject
#  3 domain of sender
#  4 email address of sender
#  5 email address of receiver
	sub sf_command {
		my($i);
		print tSOCK $_[0];
		print_LOG(">$_[0]");
		print_LOG($i = <tSOCK>);
	}

	my($iaddr,$paddr,$i);
	print_LOG("sending file $_[1] to $_[5] at address $_[0] from $_[4] in domain $_[3]\n");
	$iaddr = gethostbyname($_[0]);
	$paddr = sockaddr_in(25,$iaddr);
	socket(tSOCK, PF_INET, SOCK_STREAM, getprotobyname('tcp')) ||
		print_LOG("can't create socket in send_file\n");
	print_LOG("Socket created\n");
	connect(tSOCK, $paddr) ||
		print_LOG("can't connect to port 25 on $_[0] in send_file\n");
	print_LOG("Connected\n");
	select(tSOCK);
	$| = 1;
 	print_LOG($i = <tSOCK>);

	&sf_command("HELO $_[3]\n");
	&sf_command("MAIL FROM:$_[4]\n");
	&sf_command("RCPT TO:$_[5]\n");
	&sf_command("DATA\n");

	print tSOCK "Subject: $_[2]\n\n";

	open(TEMP,$_[1]);
	while (<TEMP>) {
		if ($_ eq ".\n") {
			print tSOCK "\\.\n";
		} else {
			print tSOCK $_;
		}
	}
	print tSOCK "\n";
	close(TEMP);

	sf_command(".\n");
	sf_command("QUIT\n");
	close(tSOCK);
}

sub cat_file {
	return unless @_;

	my $from = shift;
	my $file = shift;

	open FILE, $file or die $!;
	while (<FILE>) {
		priv_msg($from, $_);
	}
	close FILE or die $!;
}

sub search_bugtraq {
	return unless @_;

	my($j,$i,$count,$buf,$msgbuf);
	$j = lc($_[0]);

	open(TOC,"bugtraq.toc") || die $!;

	$count = read(TOC, $buf, 104);
	my ($u1,$u1,$u1,$u1,$u1,$nummsgs) =
		unpack("a6 a2 A32 c a61 v",$buf);

	priv_msg($from,"nummsgs:$nummsgs");

	for ($i = 0; $i < $nummsgs; $i++) {
		undef $msgbuf;
#		seek(TOC, 104+218*$i, 0);
		$count = read(TOC, $msgbuf, 218);
		my ($msgoffset,$msgsize,$secs,$u1,$date,$msgfrom,$msgsubj) =
			unpack("VVV a6 A32 A64 A64",$msgbuf);
		if (lc($msgsubj) =~ /$j/) {
			priv_msg($from,"[$i] From:$msgfrom -- Subject:$msgsubj -- Date:$date");
			priv_msg($from,"     MsgOffset:$msgoffset -- MsgSize:$msgsize -- Time:$secs");
		}
	}

	close(TOC);
}

sub rc5stats {
	return if ($level < 250);
	cat_file($from,"rc5stats.stats");
}

###

sub send_filebyemail {
	my(@a) = split("\@",$_[0],2);
	send_file($a[1],$_[1],$_[1],"$mailaddress","$nick\@$mailaddress",$_[0]);
}
