# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.

my (@yarnstory,@yarnplayers,$yarnmod,$yarntime);
my (@yarnlines,$yarnchan,@yarnresults,$yarnround);

my $yarnstatus	= 0;
my $yarnlevel	= 10;

sub yarn_reset {
	$yarnstatus  = 0;
	$yarnmod     = "";
	$yarntime    = 0;
	$yarnchan    = "";
	$yarnround   = 0;
	@yarnplayers = ();
	@yarnlines   = ();
	@yarnstory   = ();
	@yarnresults = ();
}

sub yarnnew {
	return if ($level < $yarnlevel);
	if ($yarnstatus > 0) {
		priv_msg($from,"$unick, a game is currently in progress. $yarnmod is the moderator");
		return;
	};
	if ($to eq $nick) {
		priv_msg($from,"$unick, yarnnew must be called from a channel");
		return;
	}
	if ($#_ < 0) {
		priv_msg($from,"$unick, syntax: yarnnew <first line of story>");
		return;
	}
	$yarnchan    = $to;
	$yarnstatus  = 1;
	$yarnmod     = $uname;
	$yarntime    = 0;
	$yarnround   = 0;
	@yarnplayers = ("$uname:0:n");
	@yarnlines   = ();	#("");
	@yarnstory   = ("@_");
	@yarnresults = ();
	priv_msg($from,"$unick, you are now the moderator of the game");
}

sub yarnchangetopic {
	return if ($level < $yarnlevel);
	if ($yarnstatus < 1) {
		priv_msg($from,"$unick, there is currently no game in progress");
		return;
	} elsif ($yarnstatus > 1) {
		priv_msg($from,"$unick, the game has already been started");
		return;
	}
	if ($yarnmod ne $uname) {
		priv_msg($from,"$unick, you are not the moderator of the current game");
		priv_msg($from,"$yarnmod is the current moderator");
		return;
	}
	if ($#_ < 0) {
		priv_msg($from,"$unick, syntax: yarnchangetopic <first line of story>");
		return;
	}
	@yarnstory = ("@_");
}

sub yarnaddplayer {
	return if ($level < $yarnlevel);
	if ($yarnstatus < 1) {
		priv_msg($from,"$unick, there is currently no game in progress");
		return;
	}# elsif ($yarnstatus > 1) {
#		priv_msg($from,"$unick, the game has already been started, no more players may be added");
#		return;
#	}
	if ($yarnmod ne $uname) {
		priv_msg($from,"$unick, you are not the moderator of the current game");
		priv_msg($from,"$yarnmod is the current moderator");
		return;
	}
	unless (@_) {
		priv_msg($from,"$unick, syntax: yarnaddplayer <player's name>");
		return;
	}
	my($i,$a);
	foreach $i (@userlist) {
		($a) = split(":",$i,2);
		if (lc($_[0]) eq lc($a)) {
			push @yarnplayers,"$a:0:n";
#			push @yarnlines,"";
			priv_msg($from,"$unick, $a added");
			return;
		}
	}
	priv_msg($from,"$unick, $_[0] was not found in the userlist, not added");
}

sub yarnremoveplayer {
	return if ($level < $yarnlevel);
	if ($yarnstatus < 1) {
		priv_msg($from,"$unick, there is currently no game in progress");
	} elsif ($yarnmod ne $uname) {
		priv_msg($from,"$unick, you are not the moderator of the current game");
		priv_msg($from,"$yarnmod is the current moderator");
	}

	my($i,@a,$x,@b);
	$x = 0;
	@b = ();
	foreach $i (@yarnplayers) {
		(@a) = split(":",$i,3);
		if ($a[0] eq lc($_[0])) {
			priv_msg($from,"$unick, $_[0] has been removed from the game");
			$x = 1;
		} else {
			push @b,$i;
		}
	}
	if (!$x) {
		priv_msg($from,"$unick, $_[0] is not a player");
	} else {
		@yarnplayers = @b;
	}
}

sub yarnchangemoderator {
	return if ($level < $yarnlevel);
	if ($yarnstatus < 1) {
		priv_msg($from,"$unick, there is currently no game in progress");
	} elsif ($yarnmod ne $uname) {
		priv_msg($from,"$unick, you are not the moderator of the current game");
		priv_msg($from,"$yarnmod is the current moderator");
	}
	unless (@_) {
		priv_msg($from,"$unick, syntax: yarnchangemoderator <player's name>");
		return;
	}
	my($i,$a);
	foreach $i (@yarnplayers) {
		(@a) = split(":",$i,3);
                if ($a[0] eq lc($_[0])) {
			$yarnmod = lc($_[0]);
			priv_msg($from,"$unick, $_[0] is now the moderator");
			return;
		}
	}
	priv_msg($from,"$unick, $_[0] is not a player");
}

sub yarnstart {
	return if ($level < $yarnlevel);
	if ($yarnmod ne $uname) {
		priv_msg($from,"$unick, you are not the moderator of the current game");
		priv_msg($from,"$yarnmod is the current moderator");
		return;
	}
	if ($yarnstatus == 0) {
		priv_msg($from,"$unick, no game has been created, use yarnnew first");
		return;
	} elsif ($yarnstatus > 1) {
		priv_msg($from,"$unick, the game has already begun");
		return;
	}
	if ($#yarnplayers < 2) {
		priv_msg($from,"$unick, atleast 3 players are needed to play");
		return;
	}

	$yarnstatus = 2;
	$yarnround  = 1;
	priv_msg($yarnchan,"YARN: the game has now begun");
}

sub yarn_nextround {
	my($i,$j,$x,@a,@b,@c);
	$yarnround++;
	$yarnstatus = 2;
	&yarn_resetyn;
	@b = (0,0,0,0,"","");
	@yarnresults = ();
	$j = 0;
	foreach $i (@yarnlines) {
		(@a) = split(":",$i,3);
		($x) = split(":",$yarnplayers[$a[1]],2);
		if (($a[0] > $b[1]) || (($a[0] == $b[1]) && (length($a[0]) > $b[2]))) {
			$b[0] = $j;
			$b[1] = $a[0];
			$b[2] = length($a[2]);
			$b[3] = $a[1];
			$b[4] = $x;
			$b[5] = $a[2];
		}
		push @yarnresults,join(":",$x,$a[0],$a[0],$a[1],$a[2]);
		$j++;
	}
	$yarnresults[$b[0]] = join(":",$b[4],$#yarnplayers+1,$b[1],$b[3],$b[5]);
	priv_msg($yarnchan,"YARN: results from last round were");
	foreach $i (@yarnresults) {
		(@a) = split(":",$i,5);
		priv_msg($yarnchan,"name: $a[0] -- score: \+$a[1] -- votes: $a[2] -- line: $a[4]");
		(@c) = split(":",$yarnplayers[$a[3]],3);
		$yarnplayers[$a[3]] = join(":",$c[0],$c[1]+$a[1],"n");
	}
	@yarnlines = ();
	priv_msg($yarnchan,"YARN: the winner of the last round was $b[4]");
	push @yarnstory,$b[5];
	priv_msg($yarnchan,"YARN: round $yarnround has now begun");
#	priv_msg($yarnchan,"YARN: the storry so far");
#	&yarntellstory;
}

sub yarntellstory {
	return if ($level < $yarnlevel);
	if ($yarnstatus < 1) {
		priv_msg($from,"$unick, no game is in progress");
		return;
	};
	my($i,$j);
	$j = 0;
	foreach $i (@yarnstory) {
		priv_msg($from,"[$j] $i");
		$j++;
	}
}

sub yarnlistplayers {
	return if ($level < $yarnlevel);
	if ($yarnstatus < 1) {
		priv_msg($from,"$unick, no game is in progress");
		return;
	}
	my($i,@a);
	foreach $i (@yarnplayers) {
		(@a) = split(":",$i,3);
		priv_msg($from,"name: $a[0] -- score: $a[1]");# -- voted/submitted: $a[2]");
	}
}

sub yarnlistlines {
	return if ($level < $yarnlevel);
	if ($yarnstatus <= 0) {
		priv_msg($from,"$unick, no game is in progress");
		return;
	} elsif ($yarnstatus == 1) {
		priv_msg($from,"$unick, the game has not begun yet");
		return;
	} elsif ($yarnstatus == 2) {
		priv_msg($from,"$unick, waitting for all players to send their lines");
		return;
	}
	my($i,$j,@a);
	$j = 0;
	foreach $i (@yarnlines) {
		(@a) = split(":",$i,3);
		priv_msg($from,"[$j] $a[2]");
		$j++;
	}
}

sub yarn_resetyn {
	my($i,@a);
	foreach $i (@yarnplayers) {
		(@a) = split(":",$i,3);
		$i   = join(":",$a[0],$a[1],"n");
	}
}

sub yarnline {
	return if ($level < $yarnlevel);
	if ($yarnstatus <= 0) {
		priv_msg($from,"$unick, no game is in progress");
		return;
	} elsif ($yarnstatus == 1) {
		priv_msg($from,"$unick, the game has not begun yet");
		return;
	} elsif ($yarnstatus == 3) {
		priv_msg($from,"$unick, waitting for players to vote");
		return;
	}
	my($i,$j,$x,@a);
	$j = 0;
	$x = 0;
	foreach $i (@yarnplayers) {
		(@a) = split(":",$i,3);
		if ($a[0] eq $uname) {
			if (lc($a[2]) eq "y") {
				priv_msg($from,"$unick, you have already submitted a sentence");
				return;
			}
			$j = 1;
			last;
		}
		$x++;
	}
	if (!$j) {
		priv_msg($from,"$unick, you are not in the player list");
		priv_msg($from,"the moderator currently is $yarnmod");
		return;
	}
	if ($#_ < 0) {
		priv_msg($from,"$unick, syntax: yarnline <sentence>");
		return;
	}
	$yarnplayers[$x] = join(":",$a[0],$a[1],"y");
	push @yarnlines,"0:$x:@_";
	priv_msg($from,"$unick, your sentence has been submitted");
	if ($#yarnlines >= $#yarnplayers) {
		$yarnstatus = 3;
		&yarn_resetyn;
		priv_msg($yarnchan,"YARN: everyone has submited a sentence, voting may now begin");
#		&yarnlistlines;
	}
}

sub yarnvote {
	return if ($level < $yarnlevel);
	if ($yarnstatus <= 0) {
		priv_msg($from,"$unick, no game is in progress");
		return;
	} elsif ($yarnstatus == 1) {
		priv_msg($from,"$unick, the game has not begun yet");
		return;
	} elsif ($yarnstatus == 2) {
		priv_msg($from,"$unick, waitting for rest of the players to vote");
		return;
	}
	my($i,$j,$x,@a,@b);
	$j = 0;
	$x = 0;
	foreach $i (@yarnplayers) {
		(@a) = split(":",$i,3);
		if ($a[0] eq $uname) {
			if ($a[2] eq "y") {
				priv_msg($from,"$unick, you have already voted");
				return;
			}
			$j = 1;
			last;
		}
		$x++;
	}
	if (!$j) {
		priv_msg($from,"$unick, you are not in the player list");
		priv_msg($from,"the moderator currently is $yarnmod");
		return;
	}
	if ($#_ < 0) {
		priv_msg($from,"$unick, syntax: yarnvote <sentence number>");
		return;
	}
	if (($_[0] > $#yarnlines) || ($_[0] < 0)) {
		priv_msg($from,"$unick, there is no sentence # $_[0]");
		return;
	}
	(@b) = split(":",$yarnlines[$_[0]],3);
	if ($b[1] == $x) {
		priv_msg($from,"$unick, you may not vote for your own sentence");
		return;
	}
	$yarnplayers[$x] = join(":",$a[0],$a[1],"y");
#	(@a) = split(":",$yarnlines[$_[0]],3);
	$yarnlines[$_[0]] = join(":",$b[0]+1,$b[1],$b[2]);
	priv_msg($from,"$unick, your vote has been tallied");
	foreach $i (@yarnplayers) {
		(@a) = split(":",$i,3);
		return if ($a[2] eq "n");
	}
	priv_msg($yarnchan,"YARN: Everyone has voted");
	&yarn_nextround;
}

1;