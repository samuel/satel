# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.

sub chord {
	return if ($level < 50);
	unless (@_) {
		priv_msg($from,"$unick, chord [chord name]");
		return;
	}

	my @tmp,$i,$j,$k,$b;
	my $newdefine = 0;
	my $chord = $_[0];
	my $f = 0;

	open(TEMP,$chordsfile);

	while (<TEMP>) {
		next if ($_ =~ /^#/);
		next unless ($_ =~ /^\{/); 
		@tmp = split(" ",$_);

		if ($tmp[0] eq "{new_define}") {
			$newdefine = 1;
		} elsif ($tmp[0] eq "{old_Define}") {
			$newdefine = 0;
		} elsif ($tmp[0] eq "{define:") {
			shift @tmp; $j = shift @tmp;
			pop @tmp;
			if ($newdefine) {
				$b = pop @tmp;
			} else {
				$b = shift @tmp;
			}
			if (lc($j) eq lc($chord)) {
				$f = 1;

				print_IRC("PRIVMSG $from :   ");
				foreach $i (@tmp) {
					if ($i eq "0") {
						print_IRC("o");
					} elsif ($i eq "x") {
						print_IRC("x");
					} else {
						print_IRC(" ");
					}
					print_IRC(" ");
				}
				print_IRC("\n");

				for($j = 1; $j <= 5; $j++) {
					print_IRC("PRIVMSG $from :   ");
					for($k = 0; $k < 11; $k++) {
						if ($k & 1 > 0) {
							print_IRC("-");
						} else {
							print_IRC("+");
						}
					}
					if ($j == 1) {
						if ($b > 9) {
							print_IRC("\nPRIVMSG $from :$b ");
						} else {
							print_IRC("\nPRIVMSG $from :$b  ");
						}
					} elsif ($j == 5) {
						print_IRC("\n");
						last;
					} else {
						print_IRC("\nPRIVMSG $from :   ");
					}
					foreach $i (@tmp) {
						if ($i eq "x" || $i eq "0") {
							print_IRC("|");
						} elsif ($i == $j) {
							print_IRC("*");
						} else {
							print_IRC("|");
						}
						print_IRC(" ");
					}
					print_IRC("\n");
				}
			}
		}
	}
	close(TEMP);

	if (!$f) {
		priv_msg($from,"$unick, chord $chord not found");
	}

}

1;