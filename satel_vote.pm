# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.


# vote file data format
#
# line #1: topic
# line #2: who has voted
# line #3: number of responses
# line #4..#4+#3: votes:response
#

sub vote_gettopic {
	my $file = $_[0];

	my($t,$nres);

	return 0 if (!($t = <$file>));
	chomp $t;
	$topic = $t;
	$who = <$file>;
	chomp $who;
	$nres = <$file>;
	chomp $nres;
	@res = ();
	for($j = 0; $j < $nres; $j++) {
		$t = <$file>;
		chomp $t;
		push @res,$t;
	}

	return 1;
}

sub vote_loadfile {
	unless(open(TEMP, $votefile)) {
		priv_msg($from,"unable to open voting file: $votefile");
		return 0;
	}
	@lines = ();
	$line = 0;
	while (<TEMP>) {
		chomp $_;
		push @lines,$_;
	} 
	close(TEMP);

	return 1;
}

sub vote_savefile {
	unless(open(TEMP, ">$votefile")) {
		priv_msg($from,"unable to create voting file: $votefile");
		return 0;
	}
	print TEMP join("\n",@lines)."\n";
	close(TEMP);

	return 1;
}

sub vote_gettopicb {
	my($t,$nres);

	return 0 if ($line > $#lines);
	$topic = $lines[$line++];
	$who = $lines[$line++];
	$nres = $lines[$line++];
	@res = ();
	for($j = 0; $j < $nres; $j++) {
		$t = $lines[$line++];
		push @res,$t;
	}

	return 1;
}

# ($list,$what)
sub if_inlist {
	my @a = split(":",$_[0]);
	my $i;
	foreach $i (@a) {
		return 1 if ($i eq $_[1]);
	}
	return 0;
}

sub votetopics {
	return if ($level < 50);

#	if (lc($from) ne lc($unick)) {
#		priv_msg($from,"all voting commands must be done through private chat");
#		return;
#	}
 
	my($i,$j,$t,$l,$vn,$sall);
	local($topic,$who,@res);
	
	if (@_) {
		$vn = $_[0];
		$sall = $_[1];
	} else {
		$vn = "0";
		$sall = "0";
	}

	unless(open(TEMP, $votefile)) {
		priv_msg($from,"unable to open voting file: $votefile");
		return;
	}

	$i = 1;

	while (vote_gettopic(TEMP)) {
		if ($vn <= 0 || $vn == $i) {
			priv_msg($from,"$i -".(if_inlist($who,$uname)?"yes":"no")."- $topic");
		};
		if ($vn == $i) {
			if (if_inlist($who,$uname)) {
				priv_msg($from,"  results:");
				$i = 1;
				foreach $l (@res) {
					($j,$t) = split(":",$l,2);
					priv_msg($from,"  $i - $j - $t");
					$i++;
				}
			} else {
				$i = 1;
				foreach $l (@res) {
					($j,$t) = split(":",$l,2);
					priv_msg($from,"  $i -- $t");
					$i++;
				}
			}

			if ($level >= 200 && $sall) {
				priv_msg($from,"  who: $who");
			}
			$i = $vn+1;
			last;
		}
		$i++;
	}
	if ($vn >= $i) {
		priv_msg($from,"no voting topic numbered $vn");
	}

	close(TEMP);
}

sub voteon {
	return if ($level < 50);

	if (lc($from) ne lc($unick)) {
		priv_msg($from,"you may only vote through private chat");
		return;
	}

	if ($#_ < 1) {
		priv_msg($from,"syntax: vote [topic number] [vote]");
		return;
	}

	my($i,@t,$vn,$v);
	local(@lines,$line,$topic,$who,@res);

	$vn = $_[0];
	$v = $_[1]-1;

	return unless (vote_loadfile());

	$i = 1;
	while (vote_gettopicb(@lines,$l) && $i++ != $vn) { };

	if ($i-1 != $vn) {
		priv_msg($from,"no voting topic numbered $vn");
	} elsif (if_inlist($who,$uname)) {
		priv_msg($from,"You have already voted on this topic");
	} elsif ($v > $#res || $v < 0) {
		priv_msg($from,"Invalid vote");
	} else {
		@t = split(":",$lines[$line-$#res-3]);
		push @t,$uname;
		$lines[$line-$#res-3] = join(":",@t);

		@t = split(":",$lines[$line-($#res+1-$v)],2);
		$t[0]++;
		$lines[$line-($#res+1-$v)] = join(":",@t);

		priv_msg($from,"Your voted has been tallied");
	}

	vote_savefile();
}

sub voteaddtopic {
	return if ($level < 50);

	my ($i,@a);

	@a = split("\\|\\|",join(" ",@_));

	if ($#a < 2) {
		priv_msg($from,"$unick, syntax: voteaddtopic topic||response1||response2||...]");
		return;
	}

	unless(open(TEMP,">>$votefile")) {
		priv_msg($from,"$unick, unable to voting file: $votefile");
		return;
	}
	while (<TEMP>) { };
	$i = shift @a;
	print TEMP "$i\n";
	print TEMP "\n";
	print TEMP ($#a+1)."\n";
	foreach $i (@a) {
		print TEMP "0:$i\n";
	}
	close(TEMP);

	priv_msg($from,"$unick, voting topic added");
}

1;