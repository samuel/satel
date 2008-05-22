# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.

my (%dwords);

my (@dict) = (
	": 2drop drop drop ;",
	": -rot rot rot ;",
	": nip swap drop ;",
	": tuck swap over ;",
	": */ -rot * swap / ;",
	": /mod 2dup mod -rot / ;",
	": pi 3.14159265358979323846 ;",
	": e 2.7182818284590452354 ;",
	": tan dup sin swap cos / ;",
	": space 1 spaces ;",
	": 1- 1 - ;",
	": 1+ 1 + ;",
	": 2* 2 * ;",
	": 2/ 2 / ;",
	": 0= 0 = ;",
	": 0< 0 < ;",
	": 0> 0 > ;",
	": 0<> 0 <> ;",
	": abs dup 0< if negate then ;",
	": bl 32 ;",
	": <= > 0= ;",
	": >= < 0= ;",
	": not 0= ;",
	": negate 0 swap - ;",
	": ?dup dup if dup then ;",
#	": invert -1 swap - ;",
	": invert -1 xor ;",
	": true -1 ;",
	": false 0 ;");

my (%words) = (
	"."		,"word_print",
	"+"		,"word_add",
	"-"		,"word_sub",
	"*"		,"word_multiply",
	"/"		,"word_divide",
	"%"		,"word_mod",
	"mod"		,"word_mod",
	"pick"		,"word_pick",
	"drop"		,"word_drop",
	"dup"		,"word_dup",
	"2dup"		,"word_2dup",
	"swap"		,"word_swap",
	"2swap"		,"word_2swap",
	"over"		,"word_over",
	"rot"		,"word_rot",
#	"tuck"		,"word_tuck",
	"**"		,"word_powerof",
	"log"		,"word_log",
	"lshift"	,"word_ls",
	"rshift"	,"word_rs",
	"sin"		,"word_sin",
	"cos"		,"word_cos",
	"atan"		,"word_atan",
	"sqrt"		,"word_sqrt",
	"hextodec"	,"word_hextodec",
	"octtodec"	,"word_octtodec",
	"dectobin"	,"word_dectobin",
	"bintodec"	,"word_bintodec",
	"emit"		,"word_emit",
	"level"		,"word_level",
	"uname"		,"word_uname",
	"unick"		,"word_unick",
	"spaces"	,"word_spaces",
	"and"		,"word_and",
	"xor"		,"word_xor",
	"or"		,"word_or",
#	"negate"	,"word_negate",
	"min"		,"word_min",
	"max"		,"word_max",
	"if"		,"word_if",
	"else"		,"word_else",
	"then"		,"word_then",
	"<"		,"word_lt",
	">"		,"word_gt",
	"="		,"word_equal",
	"<>"		,"word_notequal",
	"depth"		,"word_depth",
	"!"		,"word_store",
	"@"		,"word_fetch");

sub forth_initdict {
	my ($s,@t,$i,$j,$c);

	$c = 0;
	$j = 0;
        %dwords = ();
	foreach $s (@dict) {
		@t = split(" ",$s);
		foreach $i (@t) {
			if ($c) {
				$dwords{$i} = $j;
				$c = 0;
			} elsif ($i eq ":") {
				$c = 1;
			}
		}
		$j++;
	}
}

sub forthcomp {
	return if ($level < 200);
	return unless(@_);

	my $i;
	my $c = 0;

	push @dict,join(" ",@_);

	foreach $i (@_) {
		if ($c) {
			$dwords{$i} = $#dict;
			$c = 0;
		} elsif ($i eq ":") {
			$c = 1;
		}
	}
}

sub word_print {
	print_IRC(pop(@stack));
}

sub word_add {
	my $i = pop(@stack);
	my $j = pop(@stack);
	push @stack,($i+$j);
}

sub word_sub {
	my ($a,$b);
	$a = pop(@stack);
	$b = pop(@stack);
	push @stack,($b-$a);
}

sub word_multiply {
	my $i = pop(@stack);
	my $j = pop(@stack);
	push @stack,($i*$j);
}

sub word_divide {
	my ($a,$b);
	$a = pop(@stack);
	$b = pop(@stack);
	push @stack,($b / $a);
}

sub word_mod {
	my ($a,$b);
	$a = pop(@stack);
	$b = pop(@stack);
	push @stack,($b % $a);
}

sub word_pick {
	my $a = pop(@stack);

	if ($a <= $#stack) {
		push @stack,$stack[$#stack-$a];
	} else {
		push @stack,0;
	}
}

sub word_drop {
	pop @stack;
}

sub word_dup {
	my $a = pop(@stack);
	push @stack,($a,$a);
}

sub word_2dup {
	my ($a,$b);
	$a = pop(@stack);
	$b = pop(@stack);
	push @stack,($b,$a,$b,$a)
}

sub word_swap {
	push @stack,(pop(@stack),pop(@stack));
}

sub word_2swap {
	my ($a,$b,$c,$d);
	$a = pop(@stack);
	$b = pop(@stack);
	$c = pop(@stack);
	$d = pop(@stack);
	push @stack,($b,$a,$d,$c);
}

sub word_over {
	my $a = pop(@stack);
	my $b = pop(@stack);
	push @stack,($b,$a,$b);
}

sub word_rot {
	my ($a,$b,$c);
	$a = pop(@stack);
	$b = pop(@stack);
	$c = pop(@stack);
	push @stack,($b,$a,$c);
}

#sub word_tuck {
#	my ($a,$b);
#	$a = pop(@stack);
#	$b = pop(@stack);
#	push @stack,($a,$b,$a);
#}

sub word_powerof {
	my ($a,$b);
	$a = pop(@stack);
	$b = pop(@stack);
	push @stack,($b**$a);
}

sub word_log {
	push @stack,log(pop(@stack))
}

sub word_ls {
	my ($a,$b);
	$a = pop(@stack);
	$b = pop(@stack);
	push @stack,($b << $a);
}

sub word_rs {
	my ($a,$b);
	$a = pop(@stack);
	$b = pop(@stack);
	push @stack,($b >> $a);
}

sub word_sin {
	push @stack,sin(pop(@stack))
}

sub word_cos {
	push @stack,cos(pop(@stack))
}

sub word_atan {
	push @stack,atan2(pop(@stack),1);
}

sub word_sqrt {
	push @stack,sqrt(pop(@stack))
}

sub word_hextodec {
	push @stack,hex(pop(@stack))
}

sub word_octtodec {
	push @stack,oct(pop(@stack))
}

sub word_dectobin {
	push @stack,unpack("B32",pack("N",pop(@stack)));
}

sub word_bintodec {
	my $i = pop(@stack);
	if (length($i) > 32) {
		$i = substr($i,length($i)-32,32);
	} elsif (length($i) < 32) {
		$i = "0"x(32-length($i)).$i;
	}

	push @stack,unpack("N",pack("B32",$i));
}

sub word_emit {
	my $a = (int(pop(@stack)) & 255);
	if (($a >= 32) && ($a < 127)) {
		print_IRC(chr($a));
	}
}

sub word_level {
	push @stack,$level;
}

sub word_uname {
	push @stack,$uname;
}

sub word_unick {
	push @stack,$unick;
}

sub word_spaces {
	my $a = pop(@stack);
	if ($a <= 25) {
		print_IRC(" "x$a);
	}
}

sub word_and {
	my $a = pop(@stack);
	my $b = pop(@stack);
	push @stack,(int($a) & int($b));
}

sub word_xor {
	my $a = pop(@stack);
	my $b = pop(@stack);
	push @stack,(int($a) ^ int($b));
}

sub word_or {
	my $a = pop(@stack);
	my $b = pop(@stack);
	push @stack,(int($a) | int($b));
}

sub word_negate {
	my $a = pop(@stack);
	push @stack,-$a;
}

sub word_min {
	my $a = pop(@stack);
	my $b = pop(@stack);
	if ($a < $b) {
		push @stack,$a;
	} else {
		push @stack,$b;
	}
}

sub word_max {
	my $a = pop(@stack);
	my $b = pop(@stack);
	if ($a > $b) {
		push @stack,$a;
	} else {
		push @stack,$b;
	}
}

sub word_if {
	my $a = pop(@stack);
	if ($a) {
		push @skipem,0;
	} else {
		push @skipem,1;
	}
}

sub word_else {
	return unless(@skipem);
	my $a = pop(@skipem);
	if ($a) {
		push @skipem,0;
	} else {
		push @skipem,1;
	}
}

sub word_then {
	return unless(@skipem);
	pop @skipem;
}

sub word_lt {
	my $a = pop(@stack);
	my $b = pop(@stack);
	if ($b < $a) {
		push @stack,-1;
	} else {
		push @stack,0;
	}
}

sub word_gt {
	my $a = pop(@stack);
	my $b = pop(@stack);
	if ($b > $a) {
		push @stack,-1;
	} else {
		push @stack,0;
	}
}

sub word_equal {
	my $a = pop(@stack);
	my $b = pop(@stack);
	if ($a == $b) {
		push @stack,-1;
	} else {
		push @stack,0;
	}
}

sub word_notequal {
	my $a = pop(@stack);
	my $b = pop(@stack);
	if (@a != $b) {
		push @stack,-1;
	} else {
		push @stack,0;
	}
}

sub word_depth {
	push @stack,($#stack+1);
}

sub word_store {
	my $a = pop(@stack);
	my $b = pop(@stack);
	if ($a <= $#memory) {
		$memory[$a] = $b;
	}
}

sub word_fetch {
	my $a = pop(@stack);
	my $b = 0;
	if ($a <= $#memory) {
		$b = $memory[$a];
	}
	push @stack,$b;
}

sub word_indict {
	my ($s,$i,$t,$c,@a);

	$i = $_[0];
	$c = 0;
wi_main:while ($s = $dict[$i++]) {
		@a = split(" ",$s);
#		print "$s\n";
		foreach $t (@a) {
			if (!$c) {
				if ($t eq ":") {
					$c = 1;
				} elsif ($t eq ";") {
					last wi_main;
				} else {
					forth_word($t);
				}
			} else {
				$c = 0;
			}
		}
	}
}

sub forth_word {
	if (@skipem) {
		return if (($skipem[$#skipem]) && ($_[0] ne "else") && ($_[0] ne "then"));
	}
	if ($a = $words{$_[0]}) {
		eval($a);
	} elsif (defined($a = $dwords{$_[0]})) {
		word_indict($a);
	} else {
		push @stack,$_[0]; 
	}
}

sub forth {
	return if ($level < 50);

	local(@stack) = ();
	local(@skipem) = ();
	local($meml) = 1;
	local(@memory) = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	my($t,$a,@in);

	print_IRC("PRIVMSG $from :");
	@in = @_; #split(" ",$_[0]);
	while (@in) { #$t = shift @in) {
		$t = shift @in;
		forth_word($t);
	}
	print_IRC("\n");
}

forth_initdict;

1;