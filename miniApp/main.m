/* based on https://www.cocoawithlove.com/2010/09/minimalist-cocoa-programming.html */

#import <Cocoa/Cocoa.h>
#include "TryTracker.h"

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
    // draw once
    DocumentDraw3DData(&m_document);

    //TODO: setup event chain to react on called TrackerNotification
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp run];

    DisposeDocumentData(&m_document);
    ExitQD3D();
    return 0;
}
