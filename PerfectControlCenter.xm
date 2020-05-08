#import "PerfectControlCenter.h"
#import <Cephei/HBPreferences.h>

#define IS_iPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

static HBPreferences *pref;
static BOOL enabled;
static BOOL roundCCModules;
static BOOL hideControlCenterStatusBar;
static BOOL moveControlCenterToTheBottom;

static CGRect originalControlCenterStatusBarFrame;
static BOOL validOriginalControlCenterStatusBarFrame;

%group roundCCModulesGroup

	%hook CCUIContentModuleContentContainerView

	- (void)layoutSubviews
	{
		%orig;

		BOOL expanded = MSHookIvar<BOOL>(self, "_expanded");
		int radius = expanded ? 65 : 34;
		int numberOfSelfSubviews = [[self subviews] count];
		
		[self setClipsToBounds: YES];
		[[self layer] setCornerRadius: radius];

		if(numberOfSelfSubviews == 1)
		{
			UIView *subview1 = [self subviews][0];
			if([[subview1 subviews] count] >= 1)
			{
				UIView *subview2 = [subview1 subviews][0];
				if([subview2 isKindOfClass: %c(MediaControlsVolumeSliderView)])
				{
					[subview2 setClipsToBounds: YES];
					[[subview2 layer] setCornerRadius: radius];
				}
				else
				{
					if([[subview2 subviews] count] > 0)
					{
						UIView *subview3 = [subview2 subviews][0];
						if([[subview3 subviews] count] > 0)
						{
							UIView *subview4 = [subview3 subviews][0];
							if([[subview4 subviews] count] > 0)
							{
								UIView *subview5 = [subview4 subviews][0];
								if([subview5 isKindOfClass: %c(MTMaterialView)])
									[[subview5 layer] setCornerRadius: radius];
							}
						}
					}
				}
			}
		}
		else if(numberOfSelfSubviews > 1)
		{
			UIView *subview = [self subviews][1];
			if([subview isKindOfClass: %c(CCUIContinuousSliderView)])
				[[subview layer] setCornerRadius: radius];
		}
	}

	%end

%end

%group hideControlCenterStatusBarGroup

	%hook CCUIModularControlCenterOverlayViewController

	- (CCUIHeaderPocketView*)overlayHeaderView
	{
		return nil;
	}

	%end

%end

// Original Tweak by @himynameisubik: https://github.com/himynameisubik/StayLowCC

%group moveControlCenterToTheBottomGroup

	%hook CCUIModularControlCenterOverlayViewController

	- (void)presentAnimated: (BOOL)arg1 withCompletionHandler: (/*^block*/id)arg2
	{
		%orig;
		[self moveToBottom];
	}

	- (void)dismissAnimated: (BOOL)arg1 withCompletionHandler: (/*^block*/id)arg2
	{
		if(!hideControlCenterStatusBar)
			[self fixStatusBarOnDismiss];
		%orig;
	}

	%new
	- (void)fixStatusBarOnDismiss
	{
		if(validOriginalControlCenterStatusBarFrame)
		{
			[[self overlayHeaderView] setFrame: originalControlCenterStatusBarFrame];
			validOriginalControlCenterStatusBarFrame = NO;
		}
	}

	%new
	- (void)moveToBottom
	{
		if([self overlayInterfaceOrientation] == 1)
		{
			CGRect overlayContainerViewFrame = [[self overlayContainerView] frame];
			overlayContainerViewFrame.origin.y = 
				[[self overlayScrollView] frame].size.height - [[self overlayContainerView] frame].size.height - 124;
			[[self overlayContainerView] setFrame: overlayContainerViewFrame];

			if(!hideControlCenterStatusBar)
			{
				if(!validOriginalControlCenterStatusBarFrame)
				{
					originalControlCenterStatusBarFrame = [[self overlayHeaderView] frame];
					validOriginalControlCenterStatusBarFrame = YES;
				}
				CGRect overlayHeaderViewFrame = [[self overlayHeaderView] frame];
				overlayHeaderViewFrame.origin.y = 
					[[self overlayScrollView] frame].size.height - [[self overlayContainerView] frame].size.height 
					- [[self overlayHeaderView] frame].size.height - 20;
				[[self overlayHeaderView] setFrame: overlayHeaderViewFrame];
			}
		}
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectcontrolcenterprefs"];
		[pref registerDefaults:
		@{
			@"enabled": @NO,
			@"roundCCModules": @NO,
			@"hideControlCenterStatusBar": @NO,
			@"moveControlCenterToTheBottom": @NO
    	}];

		enabled = [pref boolForKey: @"enabled"];
		if(enabled)
		{
			roundCCModules = [pref boolForKey: @"roundCCModules"];
			hideControlCenterStatusBar = [pref boolForKey: @"hideControlCenterStatusBar"];
			moveControlCenterToTheBottom = [pref boolForKey: @"moveControlCenterToTheBottom"];

			if(roundCCModules) %init(roundCCModulesGroup);
			if(hideControlCenterStatusBar) %init(hideControlCenterStatusBarGroup);
			if(moveControlCenterToTheBottom && !IS_iPAD) %init(moveControlCenterToTheBottomGroup);
		}
	}
}