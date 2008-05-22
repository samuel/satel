# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.


sub db_find {
# filename tofind [name/info seperator] [info separator]
	return unless (@_);

	my $tf = $_[1];
	my $i = 0;
	my(@a,$j);
	unless (open(TEMP,$_[0])) {
		priv_msg($from,"$unick, database file $_[0] not found");
		return;
	}
	while (<TEMP>) {
		@a = split("\\|",$_);
		if ($a[0] =~ /$tf/i) {
			$j = shift(@a);
			select(undef, undef, undef, 0.5);
			if ($i++ > 5) {
				priv_msg($from,"$unick, too many matches found, please narrow search");
				last;
			}
			priv_msg($from,$j.$_[2].join($_[3],@a));
		}
	}
	if (!$i) {
		priv_msg($from,"$unick, no matches found");
	}
}

sub findserial {
	return if ($level < 50);
	unless (@_) {
		priv_msg($from,"$unick, syntax: findserial [program]");
		return;
	}
	db_find($serialdb,join(" ",@_)," -=- "," or ");
}

sub findgroup {
	return if ($level < 50);
	unless (@_) {
		priv_msg($from,"$unick, syntax: findgroup [group]");
		return;
	}
	db_find($groupdb,join(" ",@_)," is at "," and ");
}

sub findurl {
	return if ($level < 50);
	unless (@_) {
		priv_msg($from,"$unick, syntax: findurl [what]");
		return;
	}
	db_find($urldb,join(" ",@_)," is at "," and ");
}

sub whatis {
	return if ($level < 50);
	unless (@_) {
		priv_msg($from,"$unick, syntax: whatisit [it]");
		return;
	}
	db_find($everythingdb,join(" ",@_)," is ",", and ");
}

sub db_add {
#	my @o = split("\\|",join(" ",@_));
#	if ($#o <= 0) {
#		priv_msg($from,"$unick, syntax: addurl [what|where|where...]");
#		return;
#	}
	@o = @_;
	my $fname = shift @o;
	my $p = shift @o;
	my($i,@b);
	my @temp = ();
	if (open(TEMP,"$fname")) {
		while (<TEMP>) {
			chomp $_;
			push @temp,$_;
		}
	}
	my $j = 0;
	foreach $i (@temp) {
		@b = split("\\|",$i);
		if (lc($b[0]) eq lc($p)) {
			push @b,@o;
			$i = join("\|",@b);
			$j = 1;
			last;
		}
	}
	if (!$j) {
		push @temp,($p."|".join("\|",@o));
	}
	open(TEMP,">$fname") || return;
	print TEMP join("\n",@temp);
	close(TEMP);
}

sub addserial {
	return if ($level < 50);
	my @o = split("\\|",join(" ",@_));
	if ($#o <= 0) {
		priv_msg($from,"$unick, syntax: addserial [name|serial|serial...]");
		return;
	}
	db_add($serialdb,@o);
}

sub addurl {
	return if ($level < 50);
	my @o = split("\\|",join(" ",@_));
	if ($#o <= 0) {
		priv_msg($from,"$unick, syntax: addurl [what|where|where...]");
		return;
	}
	db_add($urldb,@o);
}

sub adddefine {
	return if ($level < 50);
	my @o = split("\\|",join(" ",@_));
	if ($#o <= 0) {
		priv_msg($from,"$unick, syntax: adddefine [it|what|what...]");
		return;
	}
	db_add($everythingdb,@o);
}

1;