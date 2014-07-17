#import "Headers.h"

static UIImage *rebootKnobImage =  [UIImage imageWithContentsOfFile:
		@"/Library/Application Support/Slide to Reboot/RebootKnob.png"];
static BOOL powerDownMode = YES;

%hook _UIActionSlider

- (void)setKnobImage:(UIImage*)image
{
	%orig();
	
	UITapGestureRecognizer *knobTap = [[UITapGestureRecognizer alloc] initWithTarget: self 
		action:@selector(knobTapped)];
	knobTap.numberOfTapsRequired = 1;
	[[self _knobView] addGestureRecognizer: knobTap];
}

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
		[self setNewKnobImage: [UIImage imageNamed: @"PowerDownKnob"]];
		powerDownMode = YES;
	}
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