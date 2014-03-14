requires 'Encode';
requires 'HTML::Strip';
requires 'IH::Plugin::Base';
requires 'Moose';
requires 'WWW::Google::AutoSuggest';
requires 'WWW::Wikipedia';
requires 'perl', '5.008_005';

on configure => sub {
    requires 'Module::Build::Tiny', '0.034';
    requires 'perl', '5.008005';
};

on test => sub {
    requires 'Test::More';
};
