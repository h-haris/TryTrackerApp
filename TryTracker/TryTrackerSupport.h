// TryTrackerSupport.h - QuickDraw 3D routines - interface
//
// Created 27th Dec 1994, Nick Thompson, DEVSUPPORT
//
// Modification History:
//
//	 5/11/95		dan v		modified for TryTracker
//	12/27/94		nick		initial version

#ifndef _TryTrackerSupport_h_
#define _TryTrackerSupport_h_

// Macintosh System Stuff
//#include <Types.h>
//#include <Windows.h>

// QuickDraw 3D stuff
/*
#include "QD3D.h"
#include "QD3DErrors.h"
#include "QD3DView.h"
*/

//for Quesa
#ifndef QUESA_OS_MACINTOSH
#define QUESA_OS_MACINTOSH
#endif

#ifndef Q3_DEBUG
#define Q3_DEBUG
#endif

#include <Quesa/Quesa.h>
#include <Quesa/QuesaErrors.h>
#include <Quesa/QuesaView.h>

//---------------------------------------------------------------------------------------

OSErr					MyQD3DInitialize(void);
OSErr					MyQD3DExit();

TQ3ViewObject			MyNewView(WindowPtr theWindow);
TQ3DrawContextObject	MyNewDrawContext(WindowPtr theWindow);
TQ3CameraObject 		MyNewCamera(WindowPtr theWindow);
TQ3GroupObject			MyNewLights(void);
TQ3GroupObject 			MyNewModel(void);

TQ3GroupObject			InputHelloWorldModel();
TQ3GroupObject			InputFactModel();

TQ3Point3D AdjustCamera(
	TQ3ViewObject		theView,
	TQ3GroupObject		mainGroup,
	short				winWidth,
	short				winHeight);


#endif
