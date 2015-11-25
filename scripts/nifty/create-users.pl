use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../vendor/lib/perl5";
use autodie qw/:system/;
use Capture::Tiny qw/:all/;
use Data::Dump qw/dump/;
use Digest::SHA qw/hmac_sha256_base64/;
use JSON;
use Lingua::JA::Numbers;
use LWP::UserAgent;

use App::Options (
    option => {
        appid => { required => 1 },
        apikey => { required => 1 },
        password => { required => 1 },
    }
);

for my $num (4, 7 .. 13, 15 .. 500) {
    create_user({
        userName => sprintf('%03d', $num),
        nickname => num2ja($num) . '松',
    });
    
    sleep int(rand 1);
}

for my $user ((
    # idk their order
    { nickname => 'トド松', userName => '005' },
    { nickname => 'おそ松', userName => '006' },
    { nickname => 'カラ松', userName => '003' },
    { nickname => 'チョロ松', userName => '002' },
    
    # 1 and 14 is special
    { nickname => '十四松', userName => '014' },
    { nickname => '一松', userName => '001' },
)) {
    create_user($user);
}

exit;

sub create_user {
    my $user = shift;
    
    $user->{password} = $App::options{password};
    $user->{profile} = "こんにちは $user->{nickname} （$user->{userName}）です";
    $user->{mailAddress} = 'n.tomita+test' . $user->{userName} . '@example.com';
    dump $user;
    
    my $req = HTTP::Request->new(
        POST => 'https://mb.api.cloud.nifty.com/2013-09-01/users',
        [
            'Content-Type' => 'application/json',
        ],
        encode_json($user)
    );

    $req = add_sign($req);
    my $res = LWP::UserAgent->new->request($req);
}

sub add_sign {
    my $req = shift;
    my $timestamp = `date -u +"%FT%T.000Z"`;
    chomp $timestamp;
    
    my $str = join("\n",
        $req->method,
        $req->uri->host,
        $req->uri->path,
        "SignatureMethod=HmacSHA256&SignatureVersion=2&X-NCMB-Application-Key=$App::options{appid}&X-NCMB-Timestamp=$timestamp",
    );
    
    my $sign = hmac_sha256_base64($str, $App::options{apikey});
    $sign .= '=' while length($sign) % 4;
    
    $req->header('X-NCMB-Application-Key' => $App::options{appid});
    $req->header('X-NCMB-Signature' => $sign);
    $req->header('X-NCMB-Timestamp' => $timestamp);
    $req;
}
