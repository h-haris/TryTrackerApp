// TryTracker.c - QuickDraw 3D routines
//
// Nick Thompson - January 6th 1994
// 
// 1994-95 Apple computer Inc., All Rights Reserved
//
// Modification History:
//
//   4/20/2021      h-haris     de-carbonized, moved to objective-c compiler
//	12/07/2003		h-haris 	carbonized; changed to quesa headers; no polling but usage of notification
//	 2/01/98		maarten 	added boxes for button states
//	 5/11/95		dan v		modified for TryTracker
//	12/27/94		nick		initial version

// c headers
#include <string.h>

#include "TryTrackerSupport.h"
#include "TryTracker.h"

#define dolog
//#undef dolog

//-------------------------------------------------------------------------------------------
// type definitions


//-------------------------------------------------------------------------------------------
// function prototypes

static void 		MainEventLoop( void ) ;


//-------------------------------------------------------------------------------------------
// globals

Boolean 		gQuitFlag 		= 0/*FALSE*/;
DocumentRec		gDocument ;

//-------------------------------------------------------------------------------------------
//

void InitQD3D(void)
{
    TQ3Status    myStatus;

    //    Initialize QuickDraw 3D, open a connection to the QuickDraw 3D library
    myStatus = Q3Initialize();

    #ifdef dolog
    if ( myStatus == kQ3Failure )
        printf("Q3Initialize returned failure.\n");
    #endif
}
    
void InitDocumentData( DocumentPtr theDocument, NSView * t_View )
{
	TQ3ControllerRef	ControllerRef,nextControllerRef;
	char				signature[256];
	char				*appleADB = "Apple Computer, Inc.:ADB:";
	TQ3Status			myStatus ;
	TQ3Switch			mySwitch = kQ3On;
	int 				i;
	
	// sets up the 3d data for the scene
	// Create view for QuickDraw 3D.
    theDocument->fView = MyNewView( t_View ) ;

    // the main display group:
	theDocument->fModel = MyNewModel() ;

	// the drawing styles:
	theDocument->fInterpolation = Q3InterpolationStyle_New(kQ3InterpolationStyleNone) ;
	theDocument->fBackFacing = Q3BackfacingStyle_New(kQ3BackfacingStyleRemove ) ;
	theDocument->fFillStyle = Q3FillStyle_New(kQ3FillStyleFilled ) ;
	theDocument->fHighlight = Q3AttributeSet_New();
	myStatus = Q3AttributeSet_Add(theDocument->fHighlight, kQ3AttributeTypeHighlightState, &mySwitch);

	// create the button state boxes
	Q3Point3D_Set(&theDocument->fButtonBoxes[0].origin, -1.6, 0, 0);
	Q3Vector3D_Set(&theDocument->fButtonBoxes[0].orientation, 0, 0.1, 0);
	Q3Vector3D_Set(&theDocument->fButtonBoxes[0].majorAxis, 0, 0, 0.1);
	Q3Vector3D_Set(&theDocument->fButtonBoxes[0].minorAxis, 0.1, 0, 0);
	theDocument->fButtonBoxes[0].faceAttributeSet = NULL;
	theDocument->fButtonBoxes[0].boxAttributeSet = NULL;
	for (i = 1; i < 16; i++) {
		theDocument->fButtonBoxes[i] = theDocument->fButtonBoxes[i-1];
		theDocument->fButtonBoxes[i].origin.x += 0.2;
	}
	// set the position and rotation
	Q3Point3D_Set(&theDocument->fPosition, 0.0, 0.0, 0.0);
	Q3Quaternion_SetIdentity(&theDocument->fRotation);
	
	// create the tracker and attach to all controllers
	theDocument->fPositionSN = 0;
	theDocument->fRotationSN = 0;
	
	//theDocument->fTracker = Q3Tracker_New(NULL);
	theDocument->fTracker = Q3Tracker_New(TrackerNotification);
	
	ControllerRef = NULL ;
	nextControllerRef = NULL;
	myStatus = Q3Controller_Next(ControllerRef, &nextControllerRef);
	if( myStatus == kQ3Success && nextControllerRef != NULL ) {
		do {
	
			/* Make sure that we aren't attaching to an ADB driver (QD3D 1.5 feature) */
			Q3Controller_GetSignature(nextControllerRef, signature, 1+(TQ3Uns32)strlen(appleADB));
			if (strcmp (signature, appleADB) != 0)
				Q3Controller_SetTracker(nextControllerRef, theDocument->fTracker);
				
			myStatus = Q3Controller_Next(nextControllerRef, &nextControllerRef) ;
			
		} while ( nextControllerRef != NULL && myStatus == kQ3Success ) ;
	}
}

void DisposeDocumentData( DocumentPtr theDocument)
{
	TQ3ControllerRef controllerRef;
	
	// release all of the controllers
	for (	Q3Controller_Next(NULL, &controllerRef);
			controllerRef != NULL;
			Q3Controller_Next(controllerRef, &controllerRef)) {
		Q3Controller_SetTracker(controllerRef, NULL);
	}
	
	Q3Object_Dispose(theDocument->fView) ;				// the view for the scene
	Q3Object_Dispose(theDocument->fModel) ;				// object in the scene being modelled
	Q3Object_Dispose(theDocument->fInterpolation) ;		// interpolation style used when rendering
	Q3Object_Dispose(theDocument->fBackFacing) ;		// whether to draw shapes that face away from the camera
	Q3Object_Dispose(theDocument->fFillStyle) ;			// whether drawn as solid filled object or decomposed to components
	Q3Object_Dispose(theDocument->fHighlight);			// whether drawn highlighted
	Q3Object_Dispose(theDocument->fTracker) ;
}
//-----------------------------------------------------------------------------
// 

TQ3Status DocumentDraw3DData( DocumentPtr theDocument )
{
	int i;
	unsigned long mask;
	
	Q3View_StartRendering(theDocument->fView);
	do {
		Q3Style_Submit( theDocument->fInterpolation, theDocument->fView );
		Q3Style_Submit( theDocument->fBackFacing, theDocument->fView );
		Q3Style_Submit( theDocument->fFillStyle, theDocument->fView );
		for (i = 0; i < 16; i++) {
			mask = 0x0001 << i;
			Q3Push_Submit(theDocument->fView);
			if (theDocument->fButtons & mask) {
				Q3AttributeSet_Submit(theDocument->fHighlight, theDocument->fView);
			}
			Q3Box_Submit(&theDocument->fButtonBoxes[i], theDocument->fView);
			Q3Pop_Submit(theDocument->fView);
		}
		
		Q3TranslateTransform_Submit( (TQ3Vector3D*) &theDocument->fPosition, theDocument->fView );
		
		#if 0
			{
				TQ3Quaternion rotation;
				
				Q3Quaternion_Invert( &theDocument->fRotation, &rotation );
				Q3QuaternionTransform_Submit( &rotation, theDocument->fView );
			}
		#else
			Q3QuaternionTransform_Submit( &theDocument->fRotation, theDocument->fView );
		#endif
		
		Q3DisplayGroup_Submit( theDocument->fModel, theDocument->fView );
	} while (Q3View_EndRendering(theDocument->fView) == kQ3ViewStatusRetraverse );
	return kQ3Success ;
}

TQ3Status TrackerNotification(TQ3TrackerObject trackerObject, TQ3ControllerRef controllerRef)
{
	TQ3Boolean			positionChanged;
	TQ3Boolean			rotationChanged;
	TQ3Quaternion		rotation, deltaRotation;
	static TQ3Quaternion	lastRotation = {1, 0, 0, 0};
	
	Q3Tracker_GetButtons(		gDocument.fTracker,
								&gDocument.fButtons);
#ifdef dolog
	if (gDocument.fButtons!=0)
        printf("keys:%.4x\n",gDocument.fButtons);
#endif										
	Q3Tracker_GetPosition(		gDocument.fTracker,
								&gDocument.fPosition,
								NULL,
								&positionChanged,
								&gDocument.fPositionSN);
	
	/* Strange: When the delta parameter is non-NULL QD3D will set the absolute rotation
		* value to 1, 0, 0, 0
		*/
	Q3Tracker_GetOrientation(	gDocument.fTracker,
								&rotation,
								NULL,
//										gDocument.fRotation,
//										NULL,
								&rotationChanged,
								&gDocument.fRotationSN);
	/* Added to check the relative rotation procedure, calculated because of remark
		* above
		*/
					
	if (rotationChanged) {
#ifdef dolog
        printf("||SN:%.4x rot: %.3f %.3f %.3f %.3f\n",gDocument.fRotationSN, rotation.w, rotation.x, rotation.y, rotation.z);
#endif
		Q3Quaternion_Invert(&lastRotation, &deltaRotation);
		Q3Quaternion_Multiply(&deltaRotation, &rotation, &deltaRotation);
		Q3Quaternion_Normalize(&deltaRotation, &deltaRotation);
		Q3Quaternion_Multiply(&gDocument.fRotation, &deltaRotation, &gDocument.fRotation);
		lastRotation = rotation;
	}
	
#ifdef dolog
	if (positionChanged)
        printf("||SN:%%.4xtrans:%.3u %.3f %.3f %.3f\n",gDocument.fPositionSN, gDocument.fPosition.x, gDocument.fPosition.y, gDocument.fPosition.z);
#endif
							
	if (positionChanged || rotationChanged) {
#if 0
		SetPort(GetWindowPort(gMainWindow));
		GetWindowBounds(gMainWindow,kWindowContentRgn,&updateRect);
		InvalWindowRect( gMainWindow,&updateRect);
#endif
	}
    return kQ3Success ;
};

//-------------------------------------------------------------------------------------------
//
void MainEventLoop()
{
#if 0
	EventRecord 	event;
	WindowPtr   	window;
	GrafPtr			curPort;
	short       	thePart;
	Rect        	screenRect;
	Rect			updateRect;
	Point			aPoint = {100, 100};

    while( !gQuitFlag )
	{
		if (WaitNextEvent( everyEvent, &event, 32767, nil ))
		{

			switch (event.what) {
				case updateEvt:
					window = (WindowPtr)event.message;
					SetPort(GetWindowPort(window));
					BeginUpdate( window );
					DocumentDraw3DData( &gDocument ) ;
					EndUpdate( window );
					break ;
			}
		}
	}
#endif
}

#if 0
//-------------------------------------------------------------------------------------------
// main()
// entry point for the application, initialize the toolbox, initialize QuickDraw 3D
// and enter the main event loop.  On exit from the main event loop, we want to call
// the QuickDraw 3D exit function to clean up QuickDraw 3d.

int carbon_main(int argc, char *argv[])
{
    TQ3Status    myStatus;

    InitQD3D();

    InitDocumentData( &gDocument, 0 ) ;
    
    MainEventLoop();
    
    DisposeDocumentData( &gDocument ) ;
    
    //    Close our connection to the QuickDraw 3D library
    myStatus = Q3Exit();
#ifdef dolog
    if ( myStatus == kQ3Failure )
        printf("Q3Exit returned failure.\n");
#endif
    
    return 0;
}
#endif
