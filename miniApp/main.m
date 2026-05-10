/* based on https://www.cocoawithlove.com/2010/09/minimalist-cocoa-programming.html */

#import <Cocoa/Cocoa.h>
#include <string.h>
#include "TryTracker.h"
#include <Quesa/QuesaController.h>

// Helper that polls for newly registered controllers and attaches the tracker.
@interface ControllerPoller : NSObject {
    DocumentPtr _doc;
    TQ3Uns32    _listSN;
}
- (instancetype)initWithDocument:(DocumentPtr)doc;
- (void)tick:(NSTimer *)t;
@end

@implementation ControllerPoller
- (instancetype)initWithDocument:(DocumentPtr)doc {
    if ((self = [super init])) { _doc = doc; _listSN = 0; }
    return self;
}
- (void)tick:(NSTimer *)t {
    TQ3Boolean changed = kQ3False;
    Q3Controller_GetListChanged(&changed, &_listSN);
    if (changed != kQ3True) return;
    TQ3ControllerRef next = NULL;
    const char *appleADB = "Apple Computer, Inc.:ADB:";
    char sig[256];
    TQ3Status s = Q3Controller_Next(NULL, &next);
    while (s == kQ3Success && next != NULL) {
        Q3Controller_GetSignature(next, sig, (TQ3Uns32)(1 + strlen(appleADB)));
        if (strcmp(sig, appleADB) != 0)
            Q3Controller_SetTracker(next, _doc->fTracker);
        s = Q3Controller_Next(next, &next);
    }
}
@end

@interface CenterAction : NSObject {
    DocumentPtr _doc;
}
- (instancetype)initWithDocument:(DocumentPtr)doc;
- (void)center:(id)sender;
@end

@implementation CenterAction
- (instancetype)initWithDocument:(DocumentPtr)doc {
    if ((self = [super init])) _doc = doc;
    return self;
}
- (void)center:(id)sender {
    CenterView(_doc);
}
@end

int main ()
{
    DocumentRec m_document; //all QD3D data structures

    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    id menubar = [NSMenu new];
    id appMenuItem = [NSMenuItem new];
    [menubar addItem:appMenuItem];
    [NSApp setMainMenu:menubar];
    id appMenu = [NSMenu new];
    id appName = [[NSProcessInfo processInfo] processName];
    id quitTitle = [@"Quit " stringByAppendingString:appName];
    id quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                                                  action:@selector(terminate:) keyEquivalent:@"q"];
    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];
    id window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 400, 400)
                                             styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:NO];
    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window setTitle:appName];
    [window makeKeyAndOrderFront:nil];
    InitQD3D();
    // call InitDocumentData, passing also: id window
    InitDocumentData(&m_document,[window contentView]);

    // View menu — Center (⌘0 resets position and rotation to origin)
    CenterAction *centerAction = [[CenterAction alloc] initWithDocument:&m_document];
    id viewMenu = [NSMenu new];
    id viewMenuItem = [[NSMenuItem alloc] initWithTitle:@"View" action:nil keyEquivalent:@""];
    NSMenuItem *centerItem = [[NSMenuItem alloc] initWithTitle:@"Center"
                                                        action:@selector(center:)
                                                 keyEquivalent:@"0"];
    [centerItem setTarget:centerAction];
    [viewMenu addItem:centerItem];
    [viewMenuItem setSubmenu:viewMenu];
    [menubar addItem:viewMenuItem];
    // draw once
    DocumentDraw3DData(&m_document);

    // Poll for new controllers that may appear after startup (e.g. SpaceMouseController
    // launched after TryTracker).  Q3Controller_GetListChanged returns kQ3True when the
    // serial number changes; re-scan and attach the tracker to any new controllers.
    ControllerPoller *poller = [[ControllerPoller alloc] initWithDocument:&m_document];
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:poller
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];

    [NSApp activateIgnoringOtherApps:YES];
    [NSApp run];

    DisposeDocumentData(&m_document);
    ExitQD3D();
    return 0;
}
