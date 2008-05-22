# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.


sub slashdotlist {
	return if ($level < 50);

	my($i);

	$i = 1;
	open(TEMP,"../slashdot.xml");
	while (<TEMP>) {
		chomp $_;
		if ($_ =~ /\<title\>/) {
			$_ =~ s/.*\<title\>//;
			$_ =~ s/\<\/title\>.*//;
			priv_msg($from,"$i - $_");
			$i++;
			select(undef, undef, undef, 0.25);
		}
	}
	close(TEMP);
}

sub slashdotread {
	return if ($level < 50);

	unless(@_) {
		priv_msg($from,"syntax: slashdotread [article number]");
		return;
	}

	my($i,$s);
	my %items = (
		"title"		=>	"",
		"url"		=>	"",
		"time"		=>	"",
		"author"	=>	"",
		"department"	=>	"",
		"topic"		=>	"",
		"comments"	=>	"",
		"section"	=>	"",
		"image"		=>	""
	);

	$i = 0;
	open(TEMP,"../slashdot.xml");
	while (<TEMP>) {
		if ($_ =~ /\<story\>/) {
			last if ((++$i) == $_[0]);
		}
	}

	if ($i != $_[0]) {
		priv_msg($from,"No such article");
		return;
	}

	while (<TEMP>) {
		chomp $_;

		last if ($_ =~ /\<\/story\>/);
		$s = $_;
		$s =~ s/\s*\<//;
		$s =~ s/\>.*//;

		$_ =~ s/\s*\<\w*\>//;
		$_ =~ s/\<.*\>//;

		$items{$s} = $_;

		priv_msg($from,sprintf("%10s: %s",$s,$_));

		select(undef, undef, undef, 0.25);
	}

	close(TEMP);
}

1;