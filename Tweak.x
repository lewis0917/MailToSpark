// MailtoSpark — Tweak.x
// iOS 18 rootless · ElleKit · Dopamine
// Intercepts mailto: URLs and recomposes them for Spark (com.readdle.smartemail)

#import <UIKit/UIKit.h>

// ─── Private LaunchServices forward declarations ──────────────────────────
// LSApplicationWorkspace bypasses LSApplicationQueriesSchemes restrictions
// that would cause canOpenURL: to return NO in any process that hasn't
// explicitly whitelisted readdle-spark in its Info.plist.

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (id)applicationProxyForIdentifier:(NSString *)bundleIdentifier;
@end


// ─── Spark availability ───────────────────────────────────────────────────

static BOOL SparkIsAvailable(void) {
    Class cls = NSClassFromString(@"LSApplicationWorkspace");
    if (!cls) return NO;
    LSApplicationWorkspace *ws = [cls performSelector:@selector(defaultWorkspace)];
    return ws && [ws applicationProxyForIdentifier:@"com.readdle.smartemail"] != nil;
}


// ─── URL conversion: mailto: → readdle-spark://compose?... ───────────────

static NSURL *_Nullable SparkURLFromMailto(NSURL *url) {
    if (!url || ![url.scheme.lowercaseString isEqualToString:@"mailto"]) return nil;
    if (!SparkIsAvailable()) return nil;

    NSURLComponents *mailto = [NSURLComponents componentsWithURL:url
                                         resolvingAgainstBaseURL:NO];

    // RFC 2368: primary address lives in path — mailto:user@host has no // authority prefix,
    // so the whole addr-spec lands in NSURLComponents.path.
    // Defensive fallback covers malformed authority-form variants (mailto://user@host).
    NSString *recipient = [mailto.path
                           stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]] ?: @"";

    if (recipient.length == 0 && mailto.user.length > 0 && mailto.host.length > 0) {
        recipient = [NSString stringWithFormat:@"%@@%@", mailto.user, mailto.host];
    }

    NSString *subject = @"", *body = @"", *cc = @"", *bcc = @"";

    for (NSURLQueryItem *item in mailto.queryItems) {
        NSString *k = item.name.lowercaseString;
        NSString *v = item.value ?: @"";

        // NSURLComponents.queryItems already yields percent-decoded values;
        // re-encoding happens automatically when we assign to spark.queryItems below.
        if      ([k isEqualToString:@"to"]      && recipient.length == 0) recipient = v;
        else if ([k isEqualToString:@"subject"])  subject = v;
        else if ([k isEqualToString:@"body"])     body    = v;
        else if ([k isEqualToString:@"cc"])       cc      = v;
        else if ([k isEqualToString:@"bcc"])      bcc     = v;
    }

    // Compose readdle-spark://compose?...
    // scheme=readdle-spark, host=compose → readdle-spark://compose
    // NSURLComponents encodes all query values on assignment — no manual work needed.
    NSURLComponents *spark = [NSURLComponents new];
    spark.scheme = @"readdle-spark";
    spark.host   = @"compose";

    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray arrayWithCapacity:5];

    if (recipient.length > 0)
        [items addObject:[NSURLQueryItem queryItemWithName:@"recipient" value:recipient]];
    if (subject.length  > 0)
        [items addObject:[NSURLQueryItem queryItemWithName:@"subject"   value:subject]];
    if (body.length     > 0)
        [items addObject:[NSURLQueryItem queryItemWithName:@"body"      value:body]];
    if (cc.length       > 0)
        [items addObject:[NSURLQueryItem queryItemWithName:@"cc"        value:cc]];
    if (bcc.length      > 0)
        [items addObject:[NSURLQueryItem queryItemWithName:@"bcc"       value:bcc]];

    spark.queryItems = items;
    return spark.URL;
}


// ─── UIApplication hooks ──────────────────────────────────────────────────

%hook UIApplication

// iOS 10+: primary URL-open path — void return, async completion block.
- (void)openURL:(NSURL *)url
            options:(NSDictionary *)options
completionHandler:(void (^)(BOOL))completion {

    NSURL *redirected = SparkURLFromMailto(url);
    if (redirected) { 
        %orig(redirected, options, completion); 
        return; 
    }
    %orig;
}

// Pre-iOS 10 legacy path — BOOL return, no options dict.
- (BOOL)openURL:(NSURL *)url {
    NSURL *redirected = SparkURLFromMailto(url);
    if (redirected) return %orig(redirected);
    return %orig;
}

%end
