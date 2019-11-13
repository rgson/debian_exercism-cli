#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use JSON::XS;
use LWP::UserAgent;


my $upstream_repo = 'exercism/cli';
my $user_agent = 'rgson/exercism-cli-debianized';
my $package_name = 'exercism-cli';

my $arch = $ARGV[0] // 'x86_64';

my $ua = LWP::UserAgent->new(agent => $user_agent, env_proxy => 1);

say 'Fetching latest Github release ...';

my $res = $ua->get(
	"https://api.github.com/repos/$upstream_repo/releases/latest",
	'Accept' => 'application/vnd.github.v3+json');
die 'Failed to get Github release: '.$res->status_line."\n"
	unless $res->is_success;
my $release = decode_json($res->decoded_content)
	or die "Failed to parse Github's response\n";
say 'Release: '.$release->{'id'}.' '.$release->{'tag_name'};

say 'Downloading the appropriate .tar.gz archive ...';

for my $asset (@{$release->{'assets'}}) {
	my ($id, $name, $url) = @$asset{qw(id name url)};
	next unless $name =~ /^exercism-([\d.]+)-linux-\Q$arch\E.tar.gz$/;
	say "Downloading: $name <$url>";
	my $orig_tar = "${package_name}_$1.orig.tar.gz";
	say " => $orig_tar";
	my $res_asset = $ua->get($url, 'Accept' => 'application/octet-stream',
		':content_file' => $orig_tar);
	die 'Failed to download asset: '.$res_asset->status_line."\n"
		unless $res_asset->is_success;
	exit;
}
die "Failed to find an appropriate .tar.gz\n";
