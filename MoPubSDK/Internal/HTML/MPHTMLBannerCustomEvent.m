//
//  MPHTMLBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPHTMLBannerCustomEvent.h"
#import "MPAdWebView.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"

@interface MPHTMLBannerCustomEvent ()

@property (nonatomic, strong) MPAdWebViewAgent *bannerAgent;
@property (nonatomic, strong) NSString *tierName;

@end

@implementation MPHTMLBannerCustomEvent

@synthesize bannerAgent = _bannerAgent;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
	self.tierName = [info objectForKey:@"name"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"trackMopubHTMLBannerAdRequested" object:self.tierName];
	
    MPLogInfo(@"Loading MoPub HTML banner");
    MPLogTrace(@"Loading banner with HTML source: %@", [[self.delegate configuration] adResponseHTMLString]);

    CGRect adWebViewFrame = CGRectMake(0, 0, size.width, size.height);
    self.bannerAgent = [[MPInstanceProvider sharedProvider] buildMPAdWebViewAgentWithAdWebViewFrame:adWebViewFrame
                                                                                           delegate:self];
    [self.bannerAgent loadConfiguration:[self.delegate configuration]];
}

- (void)dealloc
{
    self.bannerAgent.delegate = nil;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.bannerAgent rotateToOrientation:newOrientation];
}

#pragma mark - MPAdWebViewAgentDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidFinishLoadingAd:(MPAdWebView *)ad
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"trackMopubHTMLBannerAdLoaded" object:self.tierName];
	
    MPLogInfo(@"MoPub HTML banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:ad];
}

- (void)adDidFailToLoadAd:(MPAdWebView *)ad
{
    MPLogInfo(@"MoPub HTML banner did fail");
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)adDidClose:(MPAdWebView *)ad
{
    //don't care
}

- (void)adActionWillBegin:(MPAdWebView *)ad
{
    MPLogInfo(@"MoPub HTML banner will begin action");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adActionDidFinish:(MPAdWebView *)ad
{
    MPLogInfo(@"MoPub HTML banner did finish action");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adActionWillLeaveApplication:(MPAdWebView *)ad
{
    MPLogInfo(@"MoPub HTML banner will leave application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}


@end
