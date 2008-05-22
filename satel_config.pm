
# Copyright (C) 1998-2008  Samuel Stauffer <samuel@descolada.com>
# 
# See LICENSE and COPYING for license details.


$nick		= "satel";

@mudusers	= ("admin");

# IRC server info - server<:port>
#@serverlist	= ("irc.best.net","irc.mcs.com","irc.cs.cmu.edu",
#		   "ircd.erols.com","irc.core.com","irc.ais.net:6667",
#		   "irc.primenet.com");
#@serverlist	= ("irc.ais.net","irc.core.com");
#@serverlist	= ("irc.ais.net","irc.lightning.net","irc.prison.net",
#		"irc.ef.net","irc.plur.net");
@serverlist	= ("irc.ethereal.net");

$data_name	= "satel";	# $botname
$data_dir	= "$data_name.data";
$esp_dict	= "$data_dir/$data_name.esperanto";
$votefile	= "$data_dir/$data_name.votes";
$messagefile	= "$data_dir/$data_name.messages";
$usersfile	= "$data_dir/$data_name.users";
$logfile	= "$data_dir/$data_name.log";
$bkfile		= "$data_dir/$data_name.bk";
$urlfile	= "$data_dir/$data_name.urls";
$chanfile	= "$data_dir/$data_name.channels";
$helpfile	= "$data_dir/$data_name.help";
$elizafile	= "$data_dir/$data_name.eliza";
$chordsfile	= "$data_dir/$data_name.chords";
$configfile	= "$data_dir/$data_name.config";
$db_dir		= "$data_name.db";
$everythingdb	= "$db_dir/$data_name.everything";
$urldb		= "$db_dir/$data_name.urls";
$serialdb	= "$db_dir/$data_name.serials";
$groupdb	= "$db_dir/$data_name.groups";

1;
