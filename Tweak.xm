#import <Foundation/NSTask.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import "substrate.h"

@interface _UIActionSliderKnob : UIView

- (NSArray*)_subviewCache;

@end

@interface _UIActionSlider : UIView

@property (readwrite) NSString *trackText;
@property (readwrite) UIImage *knobImage;

- (_UIActionSliderKnob*)_knobView;
- (UIImageView*)knobImageView;
- (void)setNewKnobImage:(UIImage*)image;

@end

@interface UIApplication (Reboot)

- (void)reboot;

@end

@interface UIImageView (Layer)

- (CALayer*)_layer;

@end

static UIImage *rebootKnobImage = [UIImage imageWithContentsOfFile:
@"/Library/Application Support/Slide to Reboot/RebootKnob@2x.png"];
//static _UIActionSliderKnob *cachedView = nil;
static BOOL powerDownMode = YES;

%hook _UIActionSlider

%new
- (void)setNewKnobImage:(UIImage*)image
{
	UIImageView *knobImageView = MSHookIvar<UIImageView*>(self, "_knobImageView");
	UIImage *newKnobImage = [image imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
	knobImageView.image = newKnobImage;
	[knobImageView setTintColor: [UIColor redColor]];
}

%new
- (void)knobTapped
{
	if (powerDownMode){
		self.trackText = @"slide to reboot";
		[self setNewKnobImage: rebootKnobImage];
		powerDownMode = NO;
	} else {
		self.trackText = @"slide to power off";
		[self setKnobImage: [UIImage imageNamed: @"PowerDownKnob"]];
		powerDownMode = YES;
	}
}

- (void)setKnobImage:(UIImage*)image
{
	%orig();
	
	UITapGestureRecognizer *knobTap = [[UITapGestureRecognizer alloc] initWithTarget: self 
		action:@selector(knobTapped)];
	knobTap.numberOfTapsRequired = 1;
	[[self _knobView] addGestureRecognizer: knobTap];
}

%end

%hook SBPowerDownController

- (void)powerDown
{
	if (powerDownMode)
		%orig;
	else
		[[UIApplication sharedApplication] reboot];
}

%end