@interface MTMaterialView: UIView
@end

@interface CCUIContentModuleContentContainerView: UIView
- (void)setCompactContinuousCornerRadius: (double)arg1;
- (void)setExpandedContinuousCornerRadius: (double)arg1;
@end

@interface CCUIHeaderPocketView: UIView
@end

@interface CCUIModularControlCenterOverlayViewController: UIViewController
- (long long)overlayInterfaceOrientation;
- (UIView*)overlayContainerView;
- (UIScrollView*)overlayScrollView;
- (CCUIHeaderPocketView*)overlayHeaderView;
- (void)fixStatusBarOnDismiss;
- (void)moveToBottom;
@end