# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.

my (@acroplayers, $acrochan);
my (@acroanswers, $acroacro, $acrostate);

my $acromod = "";

sub acro_newacro {
	my $len = int(rand(4))+3;
	my $i;

	$acroacro = "";
	for($i = 0; $i < $len; $i++) {
		$acroacro .= chr(int(rand(26)+ord('a')));
	}
}

sub acro_newround {
	my($i,@a);
	acro_newacro;
	foreach $i (@acroanswers) {
		$i = "";
	}
	foreach $i (@acroplayers) {
		@a = split(":",$i);
		$a[2] = 0;
		$i = join(":",@a);
	}
	priv_msg($acrochan,"New Round, Acro: $acroacro");
}

sub acroreset {
	return if ($level < 50);

	$acromod = "";

	priv_msg($from,"acro game reset");
}

sub acronew {
	return if ($level < 50);

	if ($acromod ne "") {
		priv_msg($from,"An acro game is already in progress");
		return;
	}
	if ($from eq $unick) {
		priv_msg($from,"This command must be called form the channel where the game will take place");
		return;
	}

	$acromod = $uname;
	$acrochan = $from;
	$acrostate = 0;
	@acroplayers = ("$uname:0:0");
	@acroanswers = ("");
	&acro_newacro;

	priv_msg($acrochan,"An acro game has now begun in $acrochan with $acromod as the moderator");
	priv_msg($acrochan,"First acronym: $acroacro");
}

sub acroaddplayer {
	return if ($level < 50);

	if ($acromod eq "") {
		priv_msg($from,"There is currently no game in progress");
		return;
	}

	if ($acromod ne $uname) {
		priv_msg($from,"you are not the moderator");
		return;
	}

	unless(@_) {
		priv_msg($from,"syntax: acroaddplayers [player name]\n");
		return;
	}

	my($i,@a);
	foreach $i (@userlist) {
		@a = split(":",$i);
		if (lc($a[0]) eq lc($_[0])) {
			push @acroplayers,"$a[0]:0";
			push @acroanswers,"";
			priv_msg($acrochan, "$a[0] added to the game");
			return;
		}
	}

	priv_msg($from, "No users by that name");
}

sub acroscores {
	return if ($level < 50);

	if ($acromod eq "") {
		priv_msg($from,"There are no games currently in progress, you can start a new one with acronew");
		return;
	}

	my($i, @a);
	foreach $i (@acroplayers) {
		@a = split(":",$i);
		priv_msg($from,"$a[0] has a score of $a[1]");
	}
}

# (to)
sub acro_printacros {
	my($i);

	for($i = 0; $i <= $#acroplayers; $i++) {
		@a = split(":",$acroanswers[$i]);
		priv_msg($_[0],"$i - $a[2]");
	}
}

sub acro_doresults {
	my($i,$j,@a,@b);

	$j = 0;
	foreach $i (@acroanswers) {
		@a = split(":",$i);
		@b = split(":",$acroplayers[$a[1]]);
		priv_msg($acrochan,"[$a[0] votes for $b[0]] $a[2]");
		$b[1] += $a[0];
		$acroplayers[$a[1]] = join(":",@b);
		$j++;
	}
}

sub acro_findplayer {
	my($i, $j, @a);
	$j = 0;
	foreach $i (@acroplayers) {
		@a = split(":",$i);
		if (lc($_[0]) eq lc($a[0])) {
			return $j;
		}
		$j++;
	}
	return -1;
}

sub acro {
	return if ($level < 50);

	if ($from ne $unick) {
		priv_msg($from,"This command can only be done through msg");
		return;
	}

	if ($acromod eq "") {
		priv_msg($from,"There are no games currently in progress, you can start a new one with acronew");
		return;
	}

	my($i,$j,$c);
	my $ii = acro_findplayer($from);
	if ($ii < 0) {
		priv_msg($from,"You are not a player");
		return;
	}
	my @a = split(":",$acroplayers[$ii]);

	unless(@_) {
		priv_msg($from,"syntax: acro [something]");
		return;
	}

	if ($acrostate != 0) {
		priv_msg($from,"Waitting for everyone to vote to begin next round");
		return;
	}

#	if ($acroanswers[$ii] ne "") {
#		priv_msg($from,"You have already submitted");
#		return;
#	}

	foreach $i (@acroanswers) {
		next if ($i eq "");
		@a = split(":",$i);
		if ($a[1] eq $ii) {
			priv_msg($from,"You have already submitted");
			return;
		}
	}

	$j = 0;
	foreach $i (@_) {
		$c = substr($acroacro,$j,1);
		if (!($i =~ /^$c/i)) {
			priv_msg($from,"answer not valid, try again");
			return;
		}
		$j++;
	}

	while ($acroanswers[$i = int(rand($#acroplayers+1))] ne "") {};
	$acroanswers[$i] = "0:$ii:".join(" ",@_);

	priv_msg($from,"Recorded");

	$j = 0;
	foreach $i (@acroanswers) {
		if ($i eq "") {
			$j = 1;
			next;
		}
	}

	if (!$j) {
		$acrostate = 1;
		priv_msg($acrochan,"All players have submitted, voting will now commence");
		acro_printacros($acrochan);
	}
}

sub acrovote {
	return if ($level < 50);

	if ($from ne $unick) {
		priv_msg($from,"This command can only be done through msg");
		return;
	}

	if ($acromod eq "") {
		priv_msg($from,"There are no games currently in progress, you can start a new one with acronew");
		return;
	}

	my $i = acro_findplayer($from);
	if ($i < 0) {
		priv_msg($from,"You are not a player");
		return;
	}
	my @a = split(":",$acroplayers[$i]);

	unless(@_) {
		priv_msg($from,"syntax: acrovote [number]");
		return;
	}

	if ($acrostate != 1) {
		priv_msg($from,"Waitting for everyone to submit before voting");
		return;
	}

	if ($a[2]) {
		priv_msg($from,"You have already voted");
		return;
	}

	my @b = split(":",$acroanswers[$_[0]]);
	if ($b[1] == $i) {
#	if ($i == $_[0]) {
		priv_msg($from,"You may not vote for your own");
		return;
	}

	@b = split(":",$acroanswers[$_[0]]);
	$b[0]++;	# increment vote count
	$acroanswers[$_[0]] = join(":",@b);

	$a[2] = 1;	# mark player as having voted
	$acroplayers[$i] = join(":",@a);

	priv_msg($from,"Vote Tallied");

	my $j = 0;
	foreach $i (@acroplayers) {
		@b = split(":",$i);
		if (!$b[2]) {
			$j = 1;
			last;
		}
	}
	if (!$j) {
		priv_msg($acrochan,"All players have voted, the results were:");
		acro_doresults;
		$acrostate = 0;
		acro_newround;
	}

}

1;