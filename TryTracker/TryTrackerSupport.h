// TryTrackerSupport.h - QuickDraw 3D routines - interface
//
// Created 27th Dec 1994, Nick Thompson, DEVSUPPORT
//
// Modification History:
//
//   4/20/2021      h-haris     de-carbonized, moved to objective-c compiler
//   5/11/95        dan v       modified for TryTracker
//  12/27/94        nick        initial version

#ifndef _TryTrackerSupport_h_
#define _TryTrackerSupport_h_

// Macintosh System Stuff
//#include <Types.h>
//#include <Windows.h>
#include <MacTypes.h>

// QuickDraw 3D stuff

//for Quesa
#ifndef QUESA_OS_MACINTOSH
#define QUESA_OS_MACINTOSH 1
#endif

#ifndef Q3_DEBUG
#define Q3_DEBUG 1
#endif

#include <Quesa/Quesa.h>
#include <Quesa/QuesaCamera.h>
#include <Quesa/QuesaDrawContext.h>
#include <Quesa/QuesaErrors.h>
#include <Quesa/QuesaGeometry.h>
#include <Quesa/QuesaGroup.h>
#include <Quesa/QuesaLight.h>
#include <Quesa/QuesaMath.h>
#include <Quesa/QuesaRenderer.h>
#include <Quesa/QuesaSet.h>
#include <Quesa/QuesaShader.h>
#include <Quesa/QuesaStyle.h>
#include <Quesa/QuesaTransform.h>
#include <Quesa/QuesaView.h>

#include <Quesa/QuesaController.h>

//---------------------------------------------------------------------------------------

OSErr                   MyQD3DInitialize(void);
OSErr                   MyQD3DExit(void);

TQ3ViewObject           MyNewView(NSView * t_View);
TQ3DrawContextObject    MyNewDrawContext(NSView * t_View);
TQ3CameraObject         MyNewCamera(NSView * t_View);
TQ3GroupObject          MyNewLights(void);
TQ3GroupObject          MyNewModel(void);

TQ3GroupObject          InputHelloWorldModel(void);
TQ3GroupObject          InputFactModel(void);

TQ3Point3D AdjustCamera(
    TQ3ViewObject       theView,
    TQ3GroupObject      mainGroup,
    short               winWidth,
    short               winHeight);


#endif
