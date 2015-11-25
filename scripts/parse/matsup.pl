use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../vendor/lib/perl5";
use autodie qw/:system/;
use Capture::Tiny qw/:all/;
use Data::Dump qw/dump/;
use Encode;
use JSON;
use Lingua::JA::Numbers;

use App::Options (
    option => {
        appid => { required => 1 },
        apikey => { required => 1 },
        password => { required => 1 },
        sleep => { required => 1, type => 'integer', default => 20 },
    }
);

for my $num (1 .. 20) {
    warn $num;
    say_something({
        username => sprintf('%03d', $num),
        password => $App::options{password},
    });
    
    sleep $App::options{sleep};
}

exit;

sub say_something {
    my $info = shift;
    my $user = user_login($info);
    die $info if not $user;

    my $line = {
        user => { __type => 'Pointer', className => '_User', 'objectId' => $user->{objectId} },
        message => random_message($user),
        likes => int((rand 100) / 10),
    };
    
    if ($user->{username} =~ /0$/) { # **0 user is private
        $line->{ACL} = {
            "$user->{objectId}" => { read => JSON::true, write => JSON::true },
            '*' => {},
        };
    }

    system('curl',
        -X => 'POST',
        -H => "X-Parse-Application-Id: $App::options{appid}",
        -H => "X-Parse-REST-API-Key: $App::options{apikey}",
        -H => "X-Parse-Session-Token: $user->{sessionToken}",
        -H => "Content-Type: application/json",
        -d => encode_json($line),
        'https://api.parse.com/1/classes/Timeline'
    );
}

sub user_login {
    my $info = shift;
    my ($out) = capture {
        system('curl',
            -X => 'GET',
            -H => "X-Parse-Application-Id: $App::options{appid}",
            -H => "X-Parse-REST-API-Key: $App::options{apikey}",
            -H => "X-Parse-Revocable-Session: 1",
            '-G',
            '--data-urlencode' => 'username=' . $info->{username},
            '--data-urlencode' => 'password=' . $info->{password},
            'https://api.parse.com/1/login'
        );
    };
    
    return if not $out;
    return decode_json($out);
}

my @titles;
sub random_message {
    my $user = shift;
    
    if (! @titles) {
        open my $fh, '<:utf8', "$FindBin::Bin/../titles.txt";
        @titles = <$fh>;
        chomp @titles;
    }

    my $prefix = do {
        my $dt = `date +"%H:%M"`;
        chomp $dt;
        decode_utf8($dt);
    };
    
    return sprintf('%s %s、%s。',
        $prefix,
        $user->{nickname},
        $titles[ int(rand scalar @titles) ]);
}
