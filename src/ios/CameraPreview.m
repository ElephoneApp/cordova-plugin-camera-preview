#import <AssetsLibrary/AssetsLibrary.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokedUrlCommand.h>

#import "CameraPreview.h"

@implementation CameraPreview

- (void) startCamera:(CDVInvokedUrlCommand*)command {

        CDVPluginResult *pluginResult;

        if (self.sessionManager != nil) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera already started!"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
        }

        if (command.arguments.count > 3) {
                CGFloat x = (CGFloat)[command.arguments[0] floatValue] + self.webView.frame.origin.x;
                CGFloat y = (CGFloat)[command.arguments[1] floatValue] + self.webView.frame.origin.y;
                CGFloat width = (CGFloat)[command.arguments[2] floatValue];
                CGFloat height = (CGFloat)[command.arguments[3] floatValue];
                NSString *defaultCamera = command.arguments[4];
                BOOL tapToTakePicture = (BOOL)[command.arguments[5] boolValue];
                BOOL dragEnabled = (BOOL)[command.arguments[6] boolValue];
                BOOL toBack = (BOOL)[command.arguments[7] boolValue];
                // Create the session manager
                self.sessionManager = [[CameraSessionManager alloc] init];

                //render controller setup
                self.cameraRenderController = [[CameraRenderController alloc] init];
                self.cameraRenderController.dragEnabled = dragEnabled;
                self.cameraRenderController.tapToTakePicture = tapToTakePicture;
                self.cameraRenderController.sessionManager = self.sessionManager;
                self.cameraRenderController.view.frame = CGRectMake(x, y, width, height);
                self.cameraRenderController.delegate = self;

                [self.viewController addChildViewController:self.cameraRenderController];
                //display the camera bellow the webview
                if (toBack) {
                        //make transparent
                        self.webView.opaque = NO;
                        self.webView.backgroundColor = [UIColor clearColor];
                        [self.viewController.view insertSubview:self.cameraRenderController.view atIndex:0];
                }
                else{
                        self.cameraRenderController.view.alpha = (CGFloat)[command.arguments[8] floatValue];

                        [self.viewController.view addSubview:self.cameraRenderController.view];
                }

                // Setup session
                self.sessionManager.delegate = self.cameraRenderController;
                [self.sessionManager setupSession:defaultCamera];

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid number of parameters"];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) stopCamera:(CDVInvokedUrlCommand*)command {
        NSLog(@"stopCamera");
        CDVPluginResult *pluginResult;

        if(self.sessionManager != nil) {
                [self.cameraRenderController.view removeFromSuperview];
                [self.cameraRenderController removeFromParentViewController];
                self.cameraRenderController = nil;

                //[self.sessionManager.session stopRunning];
                self.sessionManager = nil;

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) hideCamera:(CDVInvokedUrlCommand*)command {
        NSLog(@"hideCamera");
        CDVPluginResult *pluginResult;

        if (self.cameraRenderController != nil) {
                [self.cameraRenderController.view setHidden:YES];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) showCamera:(CDVInvokedUrlCommand*)command {
        NSLog(@"showCamera");
        CDVPluginResult *pluginResult;

        if (self.cameraRenderController != nil) {
                [self.cameraRenderController.view setHidden:NO];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) switchCamera:(CDVInvokedUrlCommand*)command {
        NSLog(@"switchCamera");
        CDVPluginResult *pluginResult;

        if (self.sessionManager != nil) {
                [self.sessionManager switchCamera];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) setFlashMode:(CDVInvokedUrlCommand*)command {
  NSLog(@"Flash Mode");
  CDVPluginResult *pluginResult;

  NSInteger flashMode;
  NSString *errMsg;

  if (command.arguments.count <= 0)
  {
    errMsg = @"Please specify a flash mode";
  }
  else
  {
    NSString *strFlashMode = [command.arguments objectAtIndex:0];
    flashMode = [strFlashMode integerValue];
    if (flashMode != AVCaptureFlashModeOff
        && flashMode != AVCaptureFlashModeOn
        && flashMode != AVCaptureFlashModeAuto)
    {
      errMsg = @"Invalid parameter";
    }

  }

  if (errMsg) {
    NSLog(@"%@", errMsg);

  } else {
    if (self.sessionManager != nil) {
      [self.sessionManager setFlashMode:flashMode];
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
    }
  }

  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) takePicture:(CDVInvokedUrlCommand*)command {
        NSLog(@"takePicture");
        CDVPluginResult *pluginResult;

        if (self.cameraRenderController != NULL) {
                CGFloat maxW = (CGFloat)[command.arguments[0] floatValue];
                CGFloat maxH = (CGFloat)[command.arguments[1] floatValue];
                [self invokeTakePicture:maxW withHeight:maxH];
        } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera not started"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
}

-(void) setOnPictureTakenHandler:(CDVInvokedUrlCommand*)command {
        NSLog(@"setOnPictureTakenHandler");
        self.onPictureTakenHandlerId = command.callbackId;
}

-(void) setColorEffect:(CDVInvokedUrlCommand*)command {
        NSLog(@"setColorEffect");
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        NSString *filterName = command.arguments[0];

        if ([filterName isEqual: @"none"]) {
                dispatch_async(self.sessionManager.sessionQueue, ^{
                        [self.sessionManager setCiFilter:nil];
                });
        } else if ([filterName isEqual: @"mono"]) {
                dispatch_async(self.sessionManager.sessionQueue, ^{
                        CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
                        [filter setDefaults];
                        [self.sessionManager setCiFilter:filter];
                });
        } else if ([filterName isEqual: @"negative"]) {
                dispatch_async(self.sessionManager.sessionQueue, ^{
                        CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
                        [filter setDefaults];
                        [self.sessionManager setCiFilter:filter];
                });
        } else if ([filterName isEqual: @"posterize"]) {
                dispatch_async(self.sessionManager.sessionQueue, ^{
                        CIFilter *filter = [CIFilter filterWithName:@"CIColorPosterize"];
                        [filter setDefaults];
                        [self.sessionManager setCiFilter:filter];
                });
        } else if ([filterName isEqual: @"sepia"]) {
                dispatch_async(self.sessionManager.sessionQueue, ^{
                        CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
                        [filter setDefaults];
                        [self.sessionManager setCiFilter:filter];
                });
        } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Filter not found"];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void) invokeTakePicture {
        [self invokeTakePicture:0.0 withHeight:0.0];
}
- (void) invokeTakePicture:(CGFloat) maxWidth withHeight:(CGFloat) maxHeight {
        AVCaptureConnection *connection = [self.sessionManager.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        [self.sessionManager.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {

                 NSLog(@"Done creating still image");

                 if (error) {
                         NSLog(@"%@", error);
                 } else {
                         [self.cameraRenderController.renderLock lock];
                         CIImage *previewCImage = self.cameraRenderController.latestFrame;
                         CGImageRef previewImage = [self.cameraRenderController.ciContext createCGImage:previewCImage fromRect:previewCImage.extent];
                         [self.cameraRenderController.renderLock unlock];

                         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
                         UIImage *capturedImage  = [[UIImage alloc] initWithData:imageData];

                         CIImage *capturedCImage;
                         //image resize

                         if(maxWidth > 0 && maxHeight > 0) {
                                 CGFloat scaleHeight = maxWidth/capturedImage.size.height;
                                 CGFloat scaleWidth = maxHeight/capturedImage.size.width;
                                 CGFloat scale = scaleHeight > scaleWidth ? scaleWidth : scaleHeight;

                                 CIFilter *resizeFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
                                 [resizeFilter setValue:[[CIImage alloc] initWithCGImage:[capturedImage CGImage]] forKey:kCIInputImageKey];
                                 [resizeFilter setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputAspectRatio"];
                                 [resizeFilter setValue:[NSNumber numberWithFloat:scale] forKey:@"inputScale"];
                                 capturedCImage = [resizeFilter outputImage];
                         }
                         else{
                                 capturedCImage = [[CIImage alloc] initWithCGImage:[capturedImage CGImage]];
                         }

                         CIImage *imageToFilter;
                         CIImage *finalCImage;

                         //fix front mirroring
                         if (self.sessionManager.defaultCamera == AVCaptureDevicePositionFront) {
                                 CGAffineTransform matrix = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, capturedCImage.extent.size.height);
                                 imageToFilter = [capturedCImage imageByApplyingTransform:matrix];
                         } else {
                                 imageToFilter = capturedCImage;
                         }

                         CIFilter *filter = [self.sessionManager ciFilter];
                         if (filter != nil) {
                                 [self.sessionManager.filterLock lock];
                                 [filter setValue:imageToFilter forKey:kCIInputImageKey];
                                 finalCImage = [filter outputImage];
                                 [self.sessionManager.filterLock unlock];
                         } else {
                                 finalCImage = imageToFilter;
                         }

                         CGImageRef finalImage = [self.cameraRenderController.ciContext createCGImage:finalCImage fromRect:finalCImage.extent];
						 
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMddyyyy_HHmmssSS"];
            NSString *dateString = [dateFormat stringFromDate:today];
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_image.jpg",dateString]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            int count;
            NSString *dirPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@""];
            NSString *remFilePath;
            NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:NULL];
            for (count = 0; count < (int)[directoryContent count]; count++)
            {
                remFilePath =[directoryContent objectAtIndex:count];
                NSLog(@"File %d: %@", (count + 1), remFilePath);

                if ([remFilePath rangeOfString:@".jpg"].location == NSNotFound) {
                    NSLog(@"%@ was not a jpg", remFilePath);
                }
                else
                {

                    [fileManager removeItemAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:remFilePath] error:&error];
                    if (error) {
                        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);

                    }
                    else
                    {
                        NSLog(@"Successfully removed:%@ ",remFilePath);
                    }
                }
            }

            // Save image.
            UIImage *finalUImage = [[UIImage alloc] initWithCGImage:previewImage];
            [UIImageJPEGRepresentation(finalUImage,1) writeToFile:filePath atomically:YES];

                         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

                         dispatch_group_t group = dispatch_group_create();

                         __block NSString *originalPicturePath;
                         __block NSString *previewPicturePath;
                         __block NSError *photosAlbumError;

                         ALAssetOrientation orientation;
                         switch ([[UIApplication sharedApplication] statusBarOrientation]) {
                         case UIDeviceOrientationPortraitUpsideDown:
                                 orientation = ALAssetOrientationLeft;
                                 break;
                         case UIDeviceOrientationLandscapeLeft:
                                 orientation = ALAssetOrientationUp;
                                 break;
                         case UIDeviceOrientationLandscapeRight:
                                 orientation = ALAssetOrientationDown;
                                 break;
                         case UIDeviceOrientationPortrait:
                         default:
                                 orientation = ALAssetOrientationRight;
                         }

                         dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                NSMutableArray *params = [[NSMutableArray alloc] init];
                                if (photosAlbumError) {
                                        // Error returns just one element in the returned array
                                        NSString * remedy = @"";
                                        if (-3311 == [photosAlbumError code]) {
                                                remedy = @"Go to Settings > CodeStudio and allow access to Photos";
                                        }
                                        [params addObject:[NSString stringWithFormat:@"CameraPreview: %@ - %@ — %@", [photosAlbumError localizedDescription], [photosAlbumError localizedFailureReason], remedy]];
                                } else {
                                        // Success returns two elements in the returned array
                                	    //[params addObject:originalPicturePath];
                                        //[params addObject:previewPicturePath];
                                        [params addObject:filePath];
                                }

                                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:params];
                                [pluginResult setKeepCallbackAsBool:true];
                                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.onPictureTakenHandlerId];
                        });
                 }
         }];
}
@end
