# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.


sub print_IRC {
	return unless(@_);
	$idle = time;   
	print $handle $_[0];
}

sub priv_msg {
	return unless(@_);
	print_IRC("PRIVMSG $_[0] :$_[1]\n");
}

##################################### LOGS ################################
sub open_LOG {
        open(LOG,">>$logfile");
        chmod(0600,$logfile);

        select(LOG); $| = 1;
        print LOG "\n[LOG OPENED:".localtime(time)."]\n";
}

sub close_LOG {
        print LOG "[LOG CLOSED:".localtime(time)."]\n";
        close(LOG);
}

# (filename to rename current log to)
sub rotate_LOG {
	close_LOG;
	rename($logfile,$_[0]);
	open_LOG;
}

sub print_LOG {
#       print LOGFILE $_[0];

        print LOG "[".localtime(time)."] ".$_[0];
#       print STDOUT $_[0];  
	if ($config{redirectlog} ne "") {
                priv_msg($config{redirectlog},$_[0]);
        }
}

sub print_TEXTLOG {
        return if ($config{notextlog});  
        print LOG $_[0];
#       print STDOUT $_[0];
        if ($config{redirectlog} ne "") {
                priv_msg($config{redirectlog},$_[0]);
        }
}
#############################################################################

1;