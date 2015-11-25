use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../vendor/lib/perl5";
use autodie qw/:system/;
use Capture::Tiny qw/:all/;
use Data::Dump qw/dump/;
use JSON;
use Lingua::JA::Numbers;
use Time::HiRes qw/sleep/;

use App::Options (
    option => {
        appid => { required => 1 },
        apikey => { required => 1 },
    }
);

for my $num (4, 7 .. 13, 15 .. 500) {
    warn $num;
    create_user({
        nickname => num2ja($num) . '松',
        username => $num,
    });
    
    sleep 0.1;
}

for my $user ((
    # idk their order
    { nickname => 'トド松', username => '005' },
    { nickname => 'おそ松', username => '006' },
    { nickname => 'カラ松', username => '003' },
    { nickname => 'チョロ松', username => '002' },
    
    # 1 and 14 is special
    { nickname => '十四松', username => '014' },
    { nickname => '一松', username => '001' },
)) {
    create_user($user);
}

exit;

sub create_user {
    my $user = shift;
    
    $user->{password} = $App::options{password};
    $user->{profile} = "こんにちは $user->{nickname} （$user->{username}）です";

    my $filename = delete($user->{filename}) || "$user->{username}.png";
    if (not -e $filename) {
        system('wget',
            -O => $filename,
            "http://placehold.jp/780x780.png?text=$user->{username}"
        );
    }
    
    my $img = upload_image($filename);
    if ($img) {
        $user->{picture} = {
            __type => 'File',
            name => $img->{name},
        };
    }

    system(
        'curl',
        -X => 'POST',
        -H => "X-Parse-Application-Id: $App::options{appid}",
        -H => "X-Parse-REST-API-Key: $App::options{apikey}",
        -H => "X-Parse-Revocable-Session: 1",
        -H => "Content-Type: application/json",
        -d => encode_json($user),
        'https://api.parse.com/1/users'
    );
}

sub upload_image {
    my $filename = shift;
    my ($out) = capture {
        system('curl',
            -X => 'POST',
            -H => "X-Parse-Application-Id: $App::options{appid}",
            -H => "X-Parse-REST-API-Key: $App::options{apikey}",
            -H => "Content-Type: image/png",
            '--data-binary' => '@' . $filename,
            'https://api.parse.com/1/files/' . $filename
        );
    };
    
    return if not $out;
    return decode_json($out);
}    
