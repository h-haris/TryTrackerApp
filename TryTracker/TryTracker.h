// TryTracker.h - public interface (for the shell)
//
// Modification History:
//
//   4/20/2021      h-haris     de-carbonized, moved to objective-c compiler
//   4/20/2021      h-haris     move definitions from TryTracker.c here
//	 5/11/95		dan v		modified for TryTracker
//	01/01/95		nick		created this file from other stuff

#ifndef _TryTracker_h_
#define _TryTracker_h_

//for Quesa
#ifndef QUESA_OS_MACINTOSH
#define QUESA_OS_MACINTOSH 1
#endif

#ifndef Q3_DEBUG
#define Q3_DEBUG 1
#endif

#include <Quesa/Quesa.h>
#include <Quesa/QuesaGeometry.h>

struct _documentRecord {
    TQ3ViewObject       fView ;             // the view for the scene
    TQ3GroupObject      fModel ;            // object in the scene being modelled
    TQ3StyleObject      fInterpolation ;    // interpolation style used when rendering
    TQ3StyleObject      fBackFacing ;       // whether to draw shapes that face away from the camera
    TQ3StyleObject      fFillStyle ;        // whether drawn as solid filled object or decomposed to components
    TQ3AttributeSet     fHighlight;         // Added when a button is down
    TQ3Point3D          fPosition;          // the position for the center of the model
    TQ3Quaternion       fRotation;          // the rotation about the center of the model
    TQ3Uns32            fButtons;           // buttons state
    TQ3BoxData          fButtonBoxes[16];   // use to show the button states
    TQ3Uns32            fPositionSN;        // serial number for tracker position data
    TQ3Uns32            fRotationSN;        // serial number for tracker rotation data
    TQ3TrackerObject    fTracker;           // the tracker
};

typedef struct _documentRecord DocumentRec, *DocumentPtr, **DocumentHdl ;

//-------------------------------------------------------------------------------------------
//
void InitDocumentData( DocumentPtr theDocument, id t_MainWindow );
TQ3Status DocumentDraw3DData( DocumentPtr theDocument ) ;
void DisposeDocumentData( DocumentPtr theDocument) ;
TQ3Status TrackerNotification(TQ3TrackerObject trackerObject, TQ3ControllerRef controllerRef);

#endif //_TryTracker_h_
