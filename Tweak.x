#import <UIKit/UIKit.h>

static NSURL *_Nullable SparkURLFromMailto(NSURL *url) {
    if (!url || ![url.scheme.lowercaseString isEqualToString:@"mailto"]) return nil;

    NSURLComponents *mailto = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if (!mailto) return nil;

    NSString *recipient = [mailto.path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ?: @"";

    if (recipient.length == 0 && mailto.user.length > 0 && mailto.host.length > 0) {
        recipient = [NSString stringWithFormat:@"%@@%@", mailto.user, mailto.host];
    }

    NSString *subject = @"", *body = @"", *cc = @"", *bcc = @"";

    for (NSURLQueryItem *item in mailto.queryItems) {
        NSString *k = item.name.lowercaseString;
        NSString *v = item.value ?: @"";

        if      ([k isEqualToString:@"to"] && recipient.length == 0) recipient = v;
        else if ([k isEqualToString:@"subject"])  subject = v;
        else if ([k isEqualToString:@"body"])     body    = v;
        else if ([k isEqualToString:@"cc"])       cc      = v;
        else if ([k isEqualToString:@"bcc"])      bcc     = v;
    }

    NSURLComponents *spark = [NSURLComponents new];
    spark.scheme = @"readdle-spark";
    spark.host   = @"compose";

    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray arrayWithCapacity:5];

    if (recipient.length > 0) [items addObject:[NSURLQueryItem queryItemWithName:@"recipient" value:recipient]];
    if (subject.length  > 0) [items addObject:[NSURLQueryItem queryItemWithName:@"subject"   value:subject]];
    if (body.length     > 0) [items addObject:[NSURLQueryItem queryItemWithName:@"body"      value:body]];
    if (cc.length       > 0) [items addObject:[NSURLQueryItem queryItemWithName:@"cc"        value:cc]];
    if (bcc.length      > 0) [items addObject:[NSURLQueryItem queryItemWithName:@"bcc"       value:bcc]];

    spark.queryItems = items;
    return spark.URL;
}

%hook UIApplication

- (void)openURL:(NSURL *)url
            options:(NSDictionary *)options
completionHandler:(void (^)(BOOL))completion {

    if (url && [url.scheme.lowercaseString isEqualToString:@"mailto"]) {
        NSURL *redirected = SparkURLFromMailto(url);
        if (redirected && redirected.scheme) {
            %orig(redirected, options, completion);
            return;
        }
    }
    %orig;
}

- (BOOL)openURL:(NSURL *)url {
    if (url && [url.scheme.lowercaseString isEqualToString:@"mailto"]) {
        NSURL *redirected = SparkURLFromMailto(url);
        if (redirected && redirected.scheme) {
            return %orig(redirected);
        }
    }
    return %orig;
}

%end
