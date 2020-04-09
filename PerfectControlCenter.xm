#import "PerfectControlCenter.h"

#import <Cephei/HBPreferences.h>

static HBPreferences *pref;
static BOOL enabled;
static BOOL roundCCModules;

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

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectcontrolcenterprefs"];
		[pref registerDefaults:
		@{
			@"enabled": @NO,
			@"roundCCModules": @NO
    	}];

		enabled = [pref boolForKey: @"enabled"];
		if(enabled)
		{
			roundCCModules = [pref boolForKey: @"roundCCModules"];

			if(roundCCModules) %init(roundCCModulesGroup);
		}
	}
}