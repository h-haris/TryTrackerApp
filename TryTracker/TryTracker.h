// TryTracker.h - public interface for the shell
//
// Modification History:
//
//	 5/11/95		dan v		modified for TryTracker
//	01/01/95		nick		created this file from other stuff

#ifndef _TryTracker_h_
#define _TryTracker_h_
	
//-------------------------------------------------------------------------------------------
//
enum {
	mApple = 128,
	mFile,
	mEdit,
	mTest
} ;

enum {
	iAbout = 1
} ;

enum {
	iNew = 1,
	iOpen,
	iClose,
	iUnused1,
	iQuit
} ;

//-------------------------------------------------------------------------------------------
//
enum {
	iUsePictPalette = 1
} ;

//-------------------------------------------------------------------------------------------
// globals - defined in SmallShell.c
extern Boolean gQuitFlag ;


//-------------------------------------------------------------------------------------------
// constants - defined in SmallShell.c
extern const RGBColor	kRGBBlack ;
extern const RGBColor	kRGBWhite ;

// function prototypes


WindowPtr 	DoCreateBufferedWindow(	Rect *theRect, 
									const Ptr theStorage, 
									const CTabHandle theWindowCTab,
									const short theDepth, 
									const Str255 theTitle ) ;
short 		HiWrd(long aLong) ;
short 		LoWrd(long aLong) ;


#endif