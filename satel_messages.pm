# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.


####
# loads messages from file $message file
####
sub load_messages {
	my($i);
	@messages = ();
	open(TEMP,$messagefile) || return;
	while (<TEMP>) {
		chomp;
		push @messages,$_;
	}
	close(TEMP);
}

####
# saves messages to file $messagefile
####
sub save_messages {
	my($i);
	open (TEMP,">$messagefile");
	print TEMP join("\n",@messages);
	close(TEMP);
	chmod(0600,$messagefile);
}

####
# lists all messages
####
sub checkmsgs {
	return if ($level < $msg_level);

	my($i,$msg);

	$i = 0;
	foreach $msg (@messages) {
		my ($msgnum,$forwho,$fromwho,$benread,$ttime) = split(":",$msg,6);
		if ($forwho eq $uname) {
			priv_msg($from,"[$msgnum] from:$fromwho read:$benread time:".localtime($ttime)." $localtz");
			$i++;
		}
	}
	priv_msg($from,"$unick, you have no messages") if ($i == 0);
}

####
# called on join to check for unread messages
####
sub check_new {
	my($i,$j,@t);
	return if (($uflags & 2) == 0);
	$j = 0;
	foreach $i (@messages) {
		@t = split(":",$i,6);
		$j++ if (($t[1] eq $uname) && ($t[3] eq "n"));
	}
	if ($j > 0) {
		priv_msg($from,"$unick, you have $j unread messages\n");
	}
}

sub delmsg {
	return if ($level < $msg_level);
	if ($#_ < 0) {
		priv_msg($from,"$unick, delmsg needs the message number to delete");
		return;
	}

	my($mnum) = $_[0];
	my(@msgs) = ();
	my($msg);

	foreach $msg (@messages) {
		my($msgnum,$forwho,$fromwho,$benread,$ttime,$message) = split(":",$msg,6);
		if ($forwho eq $uname) {
			if ($msgnum == $mnum) {
				priv_msg($from,"$unick, msg from $fromwho deleted");
			} else {
				push @msgs,$msg
			}
		} else {
			push @msgs,$msg
		}
	}
	if ($#messages == $#msgs) {
		priv_msg($from,"$unick, message $mnum doesn't exist");
	}
	@messages = @msgs;
}

sub readmsg {
	return if ($level < $msg_level);
	if ($#_ < 0) {
		priv_msg($from,"$unick, readmsg needs the message number to read");
		return;
	}

	my $mnum = $_[0];
	my($msg);

	foreach $msg (@messages) {
		my($msgnum,$forwho,$fromwho,$benread,$ttime,$message) = split(":",$msg,6);
		if ($forwho eq $uname) {
			if ($msgnum == $mnum) {
				priv_msg($from,"from $fromwho: $message");
				$benread = "y";
				$msg = join(":",$msgnum,$forwho,$fromwho,$benread,$ttime,$message);
				return;
			}
		}
	}
	priv_msg($from,"$unick, message $mnum doesn't exist");
}

sub sendmsg {
	return if ($level < $msg_level);

	if ($#_ < 1) {
		priv_msg($from,"$unick, not enough params");
		return;
	}
	my ($mto,$msg) = split(" ",join(" ",@_),2);
	my($i,$j,$k,$tmpo);
	$k = 0;
	foreach $i (@messages) {
		($j) = split(":",$i,2);
		$k = $j if ($j > $k);
	}
	$k++;
	$k = 0 if ($k > 100000);
	$mto = lc($mto);
	foreach $i (@userlist) {
		($tmpo) = split(":",$i,2);
		if ($tmpo eq $mto) {
			push @messages,"$k:$mto:".lc($uname).":n:".time.":$msg";
			priv_msg($from,"$unick, message to $mto sent");
			return;
		}
	}
	priv_msg($from,"$unick, the name $mto is unknown to me");
}

1;
