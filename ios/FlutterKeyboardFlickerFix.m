// FlutterKeyboardFlickerFix.m
//
// Runtime backport of https://github.com/flutter/flutter/pull/182661
// for Flutter 3.41.x stable (keyboard dismiss/reopen when switching TextFields).
// Safe no-op once the engine includes the fix. Remove after upgrading past the
// regression.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>

static char kPendingInputViewRemovalKey;

static IMP sOrigClear;
static IMP sOrigHide;
static IMP sOrigSetClient;

static void fix_clearTextInputClient(id self, SEL _cmd) {
  UIView *activeView = [self valueForKey:@"activeView"];
  NSDictionary *autofillContext = [self valueForKey:@"autofillContext"];

  if (autofillContext.count == 0 && activeView.isFirstResponder) {
    SEL removeSel =
        NSSelectorFromString(@"removeEnableFlutterTextInputViewAccessibilityTimer");
    if ([self respondsToSelector:removeSel]) {
      ((void (*)(id, SEL))objc_msgSend)(self, removeSel);
    }
    [activeView setValue:@NO forKey:@"accessibilityEnabled"];
    objc_setAssociatedObject(self, &kPendingInputViewRemovalKey, @YES,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  } else {
    ((void (*)(id, SEL))sOrigClear)(self, _cmd);
    objc_setAssociatedObject(self, &kPendingInputViewRemovalKey, @NO,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
}

static void fix_hideTextInput(id self, SEL _cmd) {
  ((void (*)(id, SEL))sOrigHide)(self, _cmd);

  NSNumber *pending =
      objc_getAssociatedObject(self, &kPendingInputViewRemovalKey);
  if (pending.boolValue) {
    UIView *activeView = [self valueForKey:@"activeView"];
    UIView *inputHider = [self valueForKey:@"inputHider"];
    [activeView removeFromSuperview];
    [inputHider removeFromSuperview];
    objc_setAssociatedObject(self, &kPendingInputViewRemovalKey, @NO,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
}

static void fix_setTextInputClient(id self, SEL _cmd, int client,
                                   NSDictionary *config) {
  objc_setAssociatedObject(self, &kPendingInputViewRemovalKey, @NO,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  ((void (*)(id, SEL, int, NSDictionary *))sOrigSetClient)(self, _cmd, client,
                                                           config);
}

__attribute__((constructor)) static void installFlutterKeyboardFlickerFix(void) {
  Class cls = NSClassFromString(@"FlutterTextInputPlugin");
  if (!cls) {
    return;
  }

  Method m;

  m = class_getInstanceMethod(cls, @selector(clearTextInputClient));
  if (m) {
    sOrigClear = method_setImplementation(m, (IMP)fix_clearTextInputClient);
  }

  m = class_getInstanceMethod(cls, @selector(hideTextInput));
  if (m) {
    sOrigHide = method_setImplementation(m, (IMP)fix_hideTextInput);
  }

  m = class_getInstanceMethod(cls,
                              @selector(setTextInputClient:withConfiguration:));
  if (m) {
    sOrigSetClient = method_setImplementation(m, (IMP)fix_setTextInputClient);
  }
}
