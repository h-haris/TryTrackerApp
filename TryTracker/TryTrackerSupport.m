// TryTrackerSupport.c - QuickDraw 3D routines
//
// Nick Thompson - January 6th 1994
// 
// 1994-95 Apple computer Inc., All Rights Reserved
//
// Modification History:
//
//   4/20/2021      h-haris     de-carbonized, moved to objective-c compiler
//	12/07/2003		h-haris		carbonized; changed to quesa headers
//	 5/11/95		dan v		modified for TryTracker
//	12/27/94		nick		initial version

#include "TryTrackerSupport.h"

TQ3ViewObject MyNewView(NSView * t_View)
{
	TQ3Status				myStatus;
	TQ3ViewObject			myView;
	TQ3DrawContextObject	myDrawContext;
	TQ3RendererObject		myRenderer;
	TQ3CameraObject			myCamera;
	TQ3GroupObject			myLights;

    if ((myView = Q3View_New()) == nil )
        goto bail;

    //    Create and set draw context.
    if ((myDrawContext = MyNewDrawContext(t_View)) == nil )
        goto bail;

#if 0
    void * _Nonnull         drawContextTarget_NSView = (__bridge void * _Nonnull)(t_View);
    if ((myStatus = Q3CocoaDrawContext_SetNSView(myView, drawContextTarget_NSView)) == kQ3Failure )
        goto bail;
#endif
    
    if ((myStatus = Q3View_SetDrawContext(myView, myDrawContext)) == kQ3Failure )
        goto bail;

    Q3Object_Dispose( myDrawContext ) ;

	//	Create and set renderer.
	// this would use the interactive software renderer

	if ((myRenderer = Q3Renderer_NewFromType(kQ3RendererTypeOpenGL /*kQ3RendererTypeInteractive*/)) != nil ) {
		if ((myStatus = Q3View_SetRenderer(myView, myRenderer)) == kQ3Failure ) {
			goto bail;
		}
		// these two lines set us up to use the best possible renderer,
		// including  hardware if it is installed.
		Q3InteractiveRenderer_SetDoubleBufferBypass (myRenderer, kQ3True);						
		Q3InteractiveRenderer_SetPreferences(myRenderer, kQAVendor_BestChoice, 0);

	}
	else {
		goto bail;
	}

	if ((myStatus = Q3View_SetRenderer(myView, myRenderer)) == kQ3Failure ) {
		goto bail;
	}

	Q3Object_Dispose( myRenderer ) ;
	
	//	Create and set camera.
	if ( (myCamera = MyNewCamera(t_View)) == nil )
		goto bail;
		
	if ((myStatus = Q3View_SetCamera(myView, myCamera)) == kQ3Failure )
		goto bail;

	Q3Object_Dispose( myCamera ) ;
	
	//	Create and set lights.
	if ((myLights = MyNewLights()) == nil )
		goto bail;
		
	if ((myStatus = Q3View_SetLightGroup(myView, myLights)) == kQ3Failure )
		goto bail;
		
	Q3Object_Dispose(myLights);

	//	Done!!!
	return ( myView );
	
bail:
	//	If any of the above failed, then don't return a view.
	return ( nil );
}

//----------------------------------------------------------------------------------

#if 1
TQ3DrawContextObject MyNewDrawContext(NSView * t_View)
{
	TQ3DrawContextData		myDrawContextData;
    TQ3CocoaDrawContextData	myCocoaDrawContextData;
	TQ3ColorARGB			ClearColor;
	TQ3DrawContextObject	myDrawContext ;
	
	//	Set the background color.
	ClearColor.a = 1.0;
	ClearColor.r = 0.35;
	ClearColor.g = 0.35;
	ClearColor.b = 0.35;
	
	//	Fill in draw context data.
	myDrawContextData.clearImageMethod = kQ3ClearMethodWithColor;
	myDrawContextData.clearImageColor = ClearColor;
	myDrawContextData.paneState = kQ3False;
	myDrawContextData.maskState = kQ3False;
	myDrawContextData.doubleBufferState = kQ3True;

    myCocoaDrawContextData.drawContextData = myDrawContextData;
    myCocoaDrawContextData.nsView = (__bridge void * _Nonnull)(t_View);
    
    myDrawContext = Q3CocoaDrawContext_New(&myCocoaDrawContextData);
    
    // Sync to monitor refresh
    if (myDrawContext != nil)
    {
        TQ3Boolean    doSync = kQ3True;
        Q3Object_SetProperty( myDrawContext, kQ3DrawContextPropertySyncToRefresh,
            sizeof(doSync), &doSync );
    }

    return myDrawContext ;
}
#endif

//----------------------------------------------------------------------------------

TQ3CameraObject MyNewCamera(NSView * t_View)
{
	TQ3ViewAngleAspectCameraData	perspectiveData;
	TQ3CameraObject				camera;
	
	TQ3Point3D 					from 	= { 0.0, 0.0, 7.0 };
	TQ3Point3D 					to 		= { 0.0, 0.0, 0.0 };
	TQ3Vector3D 				up 		= { 0.0, 1.0, 0.0 };

	float 						fieldOfView = 1.0;
	float 						hither 		= 0.001;
	float 						yon 		= 1000.0;
	
	perspectiveData.cameraData.placement.cameraLocation 	= from;
	perspectiveData.cameraData.placement.pointOfInterest 	= to;
	perspectiveData.cameraData.placement.upVector 			= up;

	perspectiveData.cameraData.range.hither	= hither;
	perspectiveData.cameraData.range.yon 	= yon;

	perspectiveData.cameraData.viewPort.origin.x = -1.0;
	perspectiveData.cameraData.viewPort.origin.y = 1.0;
	perspectiveData.cameraData.viewPort.width = 2.0;
	perspectiveData.cameraData.viewPort.height = 2.0;
	
	perspectiveData.fov = fieldOfView;

    NSRect portRect = [t_View bounds];

	perspectiveData.aspectRatioXToY	=
		(float) (portRect.size.width) / (float) (portRect.size.height);
		
	camera = Q3ViewAngleAspectCamera_New(&perspectiveData);

	return camera ;
}


//----------------------------------------------------------------------------------

TQ3GroupObject MyNewLights(void)
{
	TQ3GroupPosition		myGroupPosition;
	TQ3GroupObject			myLightList;
	TQ3LightData			myLightData;
	TQ3PointLightData		myPointLightData;
	TQ3DirectionalLightData	myDirectionalLightData;
	TQ3LightObject			myAmbientLight, myPointLight, myFillLight;
	TQ3Point3D				pointLocation = { -10.0, 0.0, 10.0 };
	TQ3Vector3D				fillDirection = { 10.0, 0.0, 10.0 };
	TQ3ColorRGB				WhiteLight = { 1.0, 1.0, 1.0 };
	
	//	Set up light data for ambient light.  This light data will be used for point and fill
	//	light also.

	myLightData.isOn = kQ3True;
	myLightData.color = WhiteLight;
	
	//	Create ambient light.
	myLightData.brightness = .2;
	myAmbientLight = Q3AmbientLight_New(&myLightData);
	if ( myAmbientLight == nil )
		goto bail;
	
	//	Create point light.
	myLightData.brightness = 1.0;
	myPointLightData.lightData = myLightData;
	myPointLightData.castsShadows = kQ3False;
	myPointLightData.attenuation = kQ3AttenuationTypeNone;
	myPointLightData.location = pointLocation;
	myPointLight = Q3PointLight_New(&myPointLightData);
	if ( myPointLight == nil )
		goto bail;

	//	Create fill light.
	myLightData.brightness = .2;
	myDirectionalLightData.lightData = myLightData;
	myDirectionalLightData.castsShadows = kQ3False;
	myDirectionalLightData.direction = fillDirection;
	myFillLight = Q3DirectionalLight_New(&myDirectionalLightData);
	if ( myFillLight == nil )
		goto bail;

	//	Create light group and add each of the lights into the group.
	myLightList = Q3LightGroup_New();
	if ( myLightList == nil )
		goto bail;
	myGroupPosition = Q3Group_AddObject(myLightList, myAmbientLight);
	if ( myGroupPosition == 0 )
		goto bail;
	myGroupPosition = Q3Group_AddObject(myLightList, myPointLight);
	if ( myGroupPosition == 0 )
		goto bail;
	myGroupPosition = Q3Group_AddObject(myLightList, myFillLight);
	if ( myGroupPosition == 0 )
		goto bail;

	Q3Object_Dispose( myAmbientLight ) ;
	Q3Object_Dispose( myPointLight ) ;
	Q3Object_Dispose( myFillLight ) ;

	//	Done!
	return ( myLightList );
	
bail:
	//	If any of the above failed, then return nothing!
	return ( nil );
}




static void MyColorBoxFaces( TQ3BoxData *myBoxData )
{
	TQ3ColorRGB				faceColor ;
	short 					face ;
	
	// sanity check - you need to have set up 
	// the face attribute set for the box data 
	// before calling this.
	
	if( myBoxData->faceAttributeSet == NULL )
		return ;
		
	// make each face of a box a different color
	
	for( face = 0; face < 6; face++) {
		
		myBoxData->faceAttributeSet[face] = Q3AttributeSet_New();
		switch( face ) {
			case 0:
				faceColor.r = 1.0;
				faceColor.g = 0.0;
				faceColor.b = 0.0;
				break;
			
			case 1:
				faceColor.r = 0.0;
				faceColor.g = 1.0;
				faceColor.b = 0.0;
				break;
			
			case 2:
				faceColor.r = 0.0;
				faceColor.g = 0.0;
				faceColor.b = 1.0;
				break;
			
			case 3:
				faceColor.r = 1.0;
				faceColor.g = 1.0;
				faceColor.b = 0.0;
				break;
			
			case 4:
				faceColor.r = 1.0;
				faceColor.g = 0.0;
				faceColor.b = 1.0;
				break;
			
			case 5:
				faceColor.r = 0.0;
				faceColor.g = 1.0;
				faceColor.b = 1.0;
				break;
		}
		Q3AttributeSet_Add(myBoxData->faceAttributeSet[face], kQ3AttributeTypeDiffuseColor, &faceColor);
	}
}

static TQ3GroupPosition MyAddTransformedObjectToGroup( TQ3GroupObject theGroup, TQ3Object theObject, TQ3Vector3D *translation )
{
	TQ3TransformObject	transform;

	transform = Q3TranslateTransform_New(translation);
	Q3Group_AddObject(theGroup, transform);
	Q3Object_Dispose(transform);
	return Q3Group_AddObject(theGroup, theObject);
}


TQ3GroupObject MyNewModel()
{
	TQ3GroupObject			myGroup = NULL;
	TQ3GeometryObject		myBox;
	TQ3BoxData				myBoxData;
	TQ3ShaderObject			myIlluminationShader;
	TQ3Vector3D				translation;
	
	TQ3SetObject			faces[6];
	short					face ;
			
	// Create a group for the complete model.
	// do not use Q3OrderedDisplayGroup_New since in this
	// type of group all of the translations are applied before
	// the objects in the group are drawn, in this instance we 
	// dont want this.
	if ((myGroup = Q3DisplayGroup_New()) != NULL ) {
			
		// Define a shading type for the group
		// and add the shader to the group
		myIlluminationShader = Q3PhongIllumination_New();
		Q3Group_AddObject(myGroup, myIlluminationShader);

		// set up the colored faces for the box data
		myBoxData.faceAttributeSet = faces;
		myBoxData.boxAttributeSet = nil;
		MyColorBoxFaces( &myBoxData ) ;
		
		// create the box itself
		Q3Point3D_Set(&myBoxData.origin, -0.5, -0.5, -0.5);
		Q3Vector3D_Set(&myBoxData.orientation, .0, 1.0, .0);
		Q3Vector3D_Set(&myBoxData.majorAxis, .0, .0, 1.0);	
		Q3Vector3D_Set(&myBoxData.minorAxis, 1.0, .0, .0);	
		myBox = Q3Box_New(&myBoxData);
		
		// put four copies of the box into the group, each one with its own translation
		translation.x = -1.;translation.y = -1.;translation.z = .0;
		MyAddTransformedObjectToGroup( myGroup, myBox, &translation ) ;
		
		translation.x = 2.;translation.y = .0;translation.z = .0;
		MyAddTransformedObjectToGroup( myGroup, myBox, &translation ) ;
		
		translation.x = .0;translation.y = 2.;translation.z = .0;
		MyAddTransformedObjectToGroup( myGroup, myBox, &translation ) ;
		
		translation.x = -2.;translation.y = .0;translation.z = .0;
		MyAddTransformedObjectToGroup( myGroup, myBox, &translation ) ;
	}
	
	// dispose of the objects we created here
	if( myIlluminationShader ) 
		Q3Object_Dispose(myIlluminationShader);	
			
	for( face = 0; face < 6; face++) {
		if( myBoxData.faceAttributeSet[face] != NULL )
			Q3Object_Dispose(myBoxData.faceAttributeSet[face]);
	}
	
	if( myBox ) 
		Q3Object_Dispose( myBox );
	
	//	Done!
	return ( myGroup );
}

